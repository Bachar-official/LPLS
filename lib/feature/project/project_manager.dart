import 'dart:async';
import 'dart:io';

import 'package:lpls/constants/constants.dart';
import 'package:lpls/domain/entiy/entity.dart';
import 'package:lpls/domain/enum/enum.dart';

import 'package:lpls/feature/effect_editor/effect_manager.dart';
import 'package:lpls/feature/home/home_manager.dart';
import 'package:lpls/feature/project/project_file_manager.dart';
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
  final fileManager = ProjectFileManager();
  StreamSubscription<MidiPacket>? _midiSubscription;

  bool get isConnected => holder.rState.device != null;
  bool get isSaveAvailable => fileManager.isSaveAvailable;
  bool get isSaveAsAvailable => !isPadStructureEmpty(holder.rState.banks);

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
        warning(
          deps,
          'No stream from device',
          scaffoldMessage: 'Error while getting commands from Launchpad.',
        );
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

      final newBank = await oldBank.addFile(file, isMidi);

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
      await fileManager.exportProject(state.banks);
      success(
        deps,
        'Project file exported',
        scaffoldMessage: 'Successfully saved!',
      );
    } on ConditionException catch (e) {
      warning(deps, e.message, scaffoldMessage: e.notificationMessage);
    } catch (e, s) {
      catchException(deps, e, stackTrace: s);
    } finally {
      setLoading(false);
    }
  }

  Future<void> importProject() async {
    debug(deps, 'Try to import project');
    setLoading(true);
    try {
      final structure = await fileManager.importProject(holder.engine);
      holder.setBanks(structure);
      success(deps, 'Imported!', scaffoldMessage: 'Successfully imported');
    } on ConditionException catch (e) {
      warning(deps, e.message, scaffoldMessage: e.notificationMessage);
    } catch (e, s) {
      catchException(deps, e, stackTrace: s);
    } finally {
      setLoading(false);
    }
  }

  Future<void> saveProject({bool saveAs = false}) async {
    debug(deps, 'Trying to save project');
    setLoading(true);
    try {
      await fileManager.saveProject(state.banks, saveAs: saveAs);
      success(deps, 'Project saved', scaffoldMessage: 'Sucessfully saved!');
    } on ConditionException catch (e) {
      warning(deps, e.message, scaffoldMessage: e.notificationMessage);
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
      final structure = await fileManager.open(holder.engine, path: path);
      holder.setBanks(structure);
      success(deps, 'Project opened');
    } on ConditionException catch (e) {
      warning(deps, e.message, scaffoldMessage: e.notificationMessage);
    } catch (e, s) {
      catchException(deps, e, stackTrace: s);
    } finally {
      setLoading(false);
    }
  }

  Future<void> setVolume(double volume) async {
  if (isPadStructureEmpty(state.banks)) {
    return;
  }
  
  final updatedBanks = <int, Map<Pad, PadBank>>{};
  
  for (final entry in state.banks.entries) {
    final page = entry.key;
    final pageBanks = entry.value;
    
    final updatedPageBanks = <Pad, PadBank>{};
    
    for (final padEntry in pageBanks.entries) {
      final pad = padEntry.key;
      final bank = padEntry.value;
      
      // Создаём копию банка с обновлённой громкостью
      final updatedBank = await bank.copyWith();
      updatedBank.allVolume = volume;
      
      updatedPageBanks[pad] = updatedBank;
    }
    
    updatedBanks[page] = updatedPageBanks;
  }
  
  holder.setBanks(updatedBanks);
  holder.setVolume(volume);
}
}
