import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:lpls/constants/constants.dart';
import 'package:lpls/domain/di/di.dart';
import 'package:lpls/domain/entiy/entity.dart';
import 'package:lpls/domain/enum/enum.dart';

import 'package:lpls/feature/mobile_project/mobile_project_holder.dart';
import 'package:lpls/feature/mobile_project/mobile_project_state.dart';

import 'package:lpls/utils/utils.dart';

class MobileProjectManager {
  final MobileProjectHolder holder;
  final MobileManagerDeps deps;
  final MidiCommand midi = MidiCommand();
  StreamSubscription<MidiPacket>? _midiSubscription;
  bool get isConnected => holder.rState.device != null;

  MobileProjectManager({required this.holder, required this.deps});

  MobileProjectState get state => holder.rState;

  void setLoading(bool isLoading) => holder.setIsLoading(isLoading);

  Future<void> disconnect() async {
    mobileDebug(deps, 'Disconnecting from device ${state.device}');
    _midiSubscription?.cancel();
    if (state.device != null) {
      midi.disconnectDevice(state.device!);
      holder.setDevice(null, midi);
    }
  }

  Future<void> getDevices() async {
    await disconnect();
    setLoading(true);
    try {
      mobileDebug(deps, 'Try to get MIDI devices list');
      final devices = await midi.devices ?? [];
      for (var device in devices) {
        mobileDebug(deps, '${device.name}, ${device.id}, ${device.type}');
      }
      holder.setDevices(devices);
      mobileSuccess(deps, 'Got ${devices.length} devices');
    } catch (e, s) {
      mobileCatchException(
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
    mobileDebug(deps, 'Trying to set device to ${device?.name ?? 'Unnamed device'}');
    _midiSubscription?.cancel();
    holder.setDevice(device, midi);
    if (device != null) {
      await midi.connectToDevice(device);
      final stream = state.lpDevice?.midi.onMidiDataReceived;
      if (stream == null) {
        mobileWarning(deps, 'No stream from device', scaffoldMessage: 'Error while getting MIDI commands from device');
        return;
      }
      _midiSubscription = stream.listen(_handleMidiMessage);
      mobileSuccess(deps, 'Device set to ${state.lpDevice}');
    }
  }

  void _handleMidiMessage(MidiPacket event) async {
    // If event in "Note ON"
    if (event.data[2] == 127) {
      var pressedPad = state.lpDevice?.pressedPad(event.data[1]);
      mobileDebug(deps, 'Pressed pad: ${pressedPad?.name}');
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
            mobileCatchException(deps, e, stackTrace: s);
          }
        }
      }
      mobileDebug(deps, 'Event in ${event.data}');
    }
  }

  Future<void> importProject() async {
    mobileDebug(deps, 'Try to import project');
    setLoading(true);
    // Asking for a project file
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        // type: FileType.custom,
        // allowedExtensions: [FileExtensions.project],
      );
      if (result == null || !result.files.first.name.endsWith('.lpls')) {
        mobileWarning(
          deps,
          'file pick result is null',

          scaffoldMessage: 'There is no project to open',
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
      mobileCatchException(deps, e, stackTrace: s);
    } finally {
      setLoading(false);
    }
  }

  Future<void> openProject({String? path}) async {
    mobileDebug(deps, 'Trying to open project from file');
    setLoading(true);
    try {
      final result =
          path == null
              ? await FilePicker.platform.pickFiles(
                allowMultiple: false,
                // type: FileType.custom,
                // allowedExtensions: [FileExtensions.tempProject],
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

          padMap[pad] = await PadBank.initial(di.audioEngine).copyWith(
            midiFiles: midiPaths,
            audioFiles: audioPaths,
          );
        }

        banks[page] = padMap;
      }

      holder.setBanks(banks);
      mobileSuccess(deps, 'Project opened');
    } catch (e, s) {
      mobileCatchException(deps, e, stackTrace: s);
    } finally {
      setLoading(false);
    }
  }

  Future<void> checkLights() async {
    mobileDebug(deps, 'Try to check lights');
    try {
      for (final pad in Pad.regularPads) {
        state.lpDevice?.sendCheckSignal(pad);
      }
      await Future.delayed(const Duration(seconds: 2), () {
        for (final pad in Pad.regularPads) {
        state.lpDevice?.sendCheckSignal(pad, stop: true);
      }
      });
    } catch(e, s) {
      mobileCatchException(deps, e, stackTrace: s);
    }
  }
}
