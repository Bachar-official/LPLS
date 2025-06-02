import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lpls/constants/constants.dart';
import 'package:lpls/domain/entiy/entity.dart';
import 'package:lpls/domain/enum/enum.dart';

import 'package:lpls/feature/effect_editor/effect_manager.dart';
import 'package:lpls/feature/home/home_manager.dart';
import 'package:lpls/feature/project/project_holder.dart';

import 'package:flutter_midi_command/flutter_midi_command.dart';

import 'package:lpls/feature/project/project_state.dart';
import 'package:lpls/feature/project/utils/check_file_extension.dart';
import 'package:lpls/feature/track_editor/track_manager.dart';

import 'package:lpls/utils/utils.dart';

class ProjectManager {
  final ProjectHolder holder;
  final ManagerDeps deps;
  final EffectManager effectManager;
  final TrackManager trackManager;
  final HomeManager homeManager;
  final MidiCommand midi = MidiCommand();
  StreamSubscription<MidiPacket>? _midiSubscription;
  bool get isConnected => holder.rState.device != null;

  ProjectManager({
    required this.holder,
    required this.deps,
    required this.effectManager,
    required this.trackManager,
    required this.homeManager,
  });

  void setLoading(bool isLoading) => holder.setIsLoading(isLoading);
  ProjectState get state => holder.rState;

  Future<void> getDevices() async {
    await disconnect();
    setLoading(true);
    try {
      debug(deps, 'Try to get MIDI devices list');
      final devices = await midi.devices ?? [];
      for (var device in devices) {
        debug(deps, '${device.name}, ${device.id}, ${device.type}');
      }
      holder.setDevices(devices);
      success(deps, 'Got ${devices.length} devices');
    } catch (e, s) {
      catchException(
        deps,
        e,
        stackTrace: s,
        description: 'Error while getting MIDI devices list: ',
      );
    } finally {
      setLoading(false);
    }
  }

  Future<void> setDevice(MidiDevice? device) async {
    debug(deps, 'Trying to set device to ${device?.name ?? 'Unnamed device'}');
    _midiSubscription?.cancel();
    holder.setDevice(device, midi);
    if (device != null) {
      await midi.connectToDevice(device);
      final stream = state.lpDevice?.midi.onMidiDataReceived;
      if (stream == null) {
        warning(deps, 'No stream from device', scaffoldMessage: 'Error while getting commands from Launchpad.');
        return;
      }
      _midiSubscription = stream.listen(_handleMidiMessage);
      effectManager.setEffect(state.lpDevice!.createEffect());
      success(deps, 'Device set to ${state.lpDevice}');
    }
  }

  void _handleMidiMessage(MidiPacket event) async {
    // If event in "Note ON"
    if (event.data[2] == 127) {
      var pressedPad = state.lpDevice?.pressedPad(event.data[1]);
      debug(deps, 'Pressed pad: ${pressedPad?.name}');
      // Check if change page button pressed
      if (managingPads.contains(pressedPad)) {
        holder.setPage(pressedPad);
      } else {
        var bank = state.banks[state.page]?[pressedPad];
        if (bank != null) {
          try {
            Pad pad = pressedPad!;
            state.lpDevice?.playEffect(bank.currentEffect);
            var newBank = await bank.trigger();
            final updatedPageBanks = {
              ...state.banks[state.page]!,
              pad: newBank,
            };
            final updatedBanks = {...state.banks, state.page: updatedPageBanks};
            holder.setBanks(updatedBanks);
          } catch (e, s) {
            catchException(deps, e, stackTrace: s);
          }
        }
      }
      debug(deps, 'Event in ${event.data}');
    }
  }

  void setMode(Set<Mode> modes) => holder.setMode(modes.first);

  Future<void> disconnect() async {
    debug(deps, 'Disconnecting from device ${state.device}');
    _midiSubscription?.cancel();
    if (state.device != null) {
      midi.disconnectDevice(state.device!);
      holder.setDevice(null, midi);
    }
  }

  void sendCheckSignal(Pad pad, {bool stop = false}) =>
      state.lpDevice?.sendCheckSignal(pad, stop: stop);

  void addFileToPad(
    int page,
    Pad pad,
    File file, {
    required bool isMidi,
  }) async {
    setLoading(true);
    try {
      checkFileExtension(state.mode, file);

      final oldBank = state.banks[page]?[pad];
      if (oldBank == null) return;

      final newBank = PadBank(
        audioFiles: [...oldBank.audioFiles],
        audioPlayers: [...oldBank.audioPlayers],
        midiFiles: [...oldBank.midiFiles],
        effects: [...oldBank.effects],
        audioIndex: oldBank.audioIndex,
        midiIndex: oldBank.midiIndex,
      );

      await newBank.addFile(file, isMidi);

      final newBanks = PadStructure.from(state.banks);
      final pageBanks = Map<Pad, PadBank>.from(newBanks[page] ?? {});
      pageBanks[pad] = newBank;
      newBanks[page] = pageBanks;

      holder.setBanks(newBanks);
    } catch (e, s) {
      catchException(deps, e, stackTrace: s);
    } finally {
      setLoading(false);
    }
  }

  Future<void> removeFileFromBank({
    required Pad pad,
    required PadBank bank,
    required int index,
    required bool isMidi,
  }) async {
    final newBank = await bank.removeFile(index, isMidi);
    setBank(newBank, pad);
    selectPad(pad);
  }

  void setBank(PadBank bank, Pad pad) {
    final newBanks = PadStructure.from(state.banks);
    final pageBanks = Map<Pad, PadBank>.from(newBanks[state.page] ?? {});
    pageBanks[pad] = bank;
    newBanks[state.page] = pageBanks;
    holder.setBanks(newBanks);
  }

  void selectPad(Pad pad) {
    trackManager.setBank(state.banks[state.page]?[pad]);
    trackManager.setPad(pad);
    homeManager.toTrackScreen();
  }

  Future<void> exportProject() async {
    debug(deps, 'Try to export project');
    setLoading(true);
    try {
      // Asking for save location
      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Export project to...',
        fileName: FileExtensions.projectFileName,
      );
      final baseName =
          path != null
              ? path.split(Platform.pathSeparator).last.split('.').first
              : 'project';
      // If no path is selected
      if (path == null) {
        warning(
          deps,
          'File saving cancelled',

          scaffoldMessage: 'Cancelled saving file',
        );
        return;
      }
      // Creating temp directories
      final tempDir = await Directory.systemTemp.createTemp('lpls_temp_');
      final effectsDir = Directory('${tempDir.path}/effects');
      final audioDir = Directory('${tempDir.path}/audio');
      await effectsDir.create(recursive: true);
      await audioDir.create(recursive: true);

      // Serializing project and copying files
      final serializedBanks =
          <String, Map<String, Map<String, List<String>>>>{};

      for (final bankEntry in state.banks.entries) {
        final bankIndex = bankEntry.key;
        final serializedPadMap = <String, Map<String, List<String>>>{};

        for (final padEntry in bankEntry.value.entries) {
          final pad = padEntry.key;
          final bank = padEntry.value;

          final updatedMidiPaths = <String>[];
          for (final file in bank.midiFiles) {
            final newPath = '${effectsDir.path}/${file.uri.pathSegments.last}';
            await file.copy(newPath);
            updatedMidiPaths.add('effects/${file.uri.pathSegments.last}');
          }

          final updatedAudioPaths = <String>[];
          for (final file in bank.audioFiles) {
            final newPath = '${audioDir.path}/${file.uri.pathSegments.last}';
            await file.copy(newPath);
            updatedAudioPaths.add('audio/${file.uri.pathSegments.last}');
          }

          serializedPadMap[pad.name] = {
            'midiFiles': updatedMidiPaths,
            'audioFiles': updatedAudioPaths,
          };
        }

        serializedBanks[bankIndex.toString()] = serializedPadMap;
      }

      // Writing lpp file and archiving at ZIP
      final projectJson = jsonEncode(serializedBanks);
      final lppFile = File('${tempDir.path}/$baseName.lpp');
      await lppFile.writeAsString(projectJson);

      final encoder = ZipEncoder();
      final archive = Archive();

      for (final entity in tempDir.listSync(recursive: true)) {
        if (entity is File) {
          final relativePath = entity.path.substring(tempDir.path.length + 1);
          final data = await entity.readAsBytes();
          archive.addFile(ArchiveFile(relativePath, data.length, data));
        }
      }

      final zipData = encoder.encode(archive);
      final outFile = File(path);
      await outFile.writeAsBytes(zipData);

      // Deleting temp dir and writing success message
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }

      success(
        deps,
        'Project file exported',
        scaffoldMessage: 'Successfully saved as $baseName.lpls',
      );
    } catch (e, s) {
      catchException(deps, e, stackTrace: s);
    } finally {
      setLoading(false);
    }
  }

  Future<void> importProject() async {
    debug(deps, 'Try to import project');
    setLoading(true);
    // Asking for a project file
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: [FileExtensions.project],
      );
      if (result == null) {
        warning(
          deps,
          'file pick result is null',

          scaffoldMessage: 'There is no file to open',
        );
        return;
      }
      final baseName =
          result.paths.last != null
              ? result.paths.last!
                  .split(Platform.pathSeparator)
                  .last
                  .split('.')
                  .first
              : 'project';

      final baseDirectory = FileUtils.getBasePath(result.paths.last!);
      await FileUtils.extractLpls(
        result.paths.last!,
        '$baseDirectory/$baseName',
      );
      await openProject(path: '$baseDirectory/$baseName/$baseName.lpp');
    } catch (e, s) {
      catchException(deps, e, stackTrace: s);
    } finally {
      setLoading(false);
    }
  }

  Future<void> saveProject() async {
    debug(deps, 'Trying to save project');
    setLoading(true);
    try {
      var path = await FilePicker.platform.saveFile(
        dialogTitle: 'Save project',
        fileName: FileExtensions.tempProjectFileName,
      );
      if (path == null) {
        warning(
          deps,
          'Cancelled file saving',

          scaffoldMessage: 'File saving cancelled',
        );
        setLoading(false);
        return;
      }
      debug(deps, PadStructureSerializer.serialize(state.banks).toString());
      final content = jsonEncode(PadStructureSerializer.serialize(state.banks));
      await File(path).writeAsString(content);
      success(
        deps,
        'Project saved as $path',

        scaffoldMessage: 'Sucessfully saved as $path',
      );
    } catch (e, s) {
      catchException(deps, e, stackTrace: s);
    } finally {
      setLoading(false);
    }
  }

  Future<void> openProject({String? path}) async {
    debug(deps, 'Trying to open project from file');
    setLoading(true);
    try {
      final result =
          path == null
              ? await FilePicker.platform.pickFiles(
                allowMultiple: false,
                type: FileType.custom,
                allowedExtensions: [FileExtensions.tempProject],
              )
              : null;

      final filePath = path ?? result?.files.single.path;
      if (filePath == null) return;

      final file = File(filePath);
      final jsonString = await file.readAsString();
      final Map<String, dynamic> decoded = jsonDecode(jsonString);

      final baseDir = FileUtils.getBasePath(filePath);

      final banks = <int, Map<Pad, PadBank>>{};
      for (final bankEntry in decoded.entries) {
        final page = int.parse(bankEntry.key);
        final padMap = <Pad, PadBank>{};

        for (final padEntry in (bankEntry.value as Map).entries) {
          final pad = Pad.values.firstWhere((p) => p.name == padEntry.key);
          final data = padEntry.value as Map;

          final midiPaths =
              (data['midiFiles'] as List).map((relPath) {
                return File('$baseDir/$relPath');
              }).toList();

          final audioPaths =
              (data['audioFiles'] as List).map((relPath) {
                return File('$baseDir/$relPath');
              }).toList();

          padMap[pad] = await PadBank.initial().copyWith(
            midiFiles: midiPaths,
            audioFiles: audioPaths,
          );
        }

        banks[page] = padMap;
      }

      holder.setBanks(banks);
      success(deps, 'Project opened');
    } catch (e, s) {
      catchException(deps, e, stackTrace: s);
    } finally {
      setLoading(false);
    }
  }
}
