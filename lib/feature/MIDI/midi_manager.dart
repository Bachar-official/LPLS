import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lpls/constants/paging_pads.dart';
import 'package:lpls/domain/entiy/launchpad/launchpad_device.dart';
import 'package:lpls/domain/entiy/launchpad/launchpad_factory.dart';
import 'package:lpls/domain/entiy/manager_deps.dart';
import 'package:lpls/domain/enum/mode.dart';
import 'package:lpls/domain/enum/color_mk1.dart';
import 'package:lpls/domain/enum/pad.dart';
import 'package:lpls/feature/MIDI/midi_holder.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:lpls/feature/MIDI/midi_state.dart';
import 'package:lpls/utils/ui_utils.dart';

class MidiManager {
  final MidiHolder holder;
  final ManagerDeps deps;
  final MidiCommand midi = MidiCommand();
  final TextEditingController vText = TextEditingController();
  LaunchpadDevice? lpDevice;
  bool get isConnected => holder.rState.device != null;

  MidiManager({required this.holder, required this.deps});

  void setLoading(bool isLoading) => holder.setIsLoading(isLoading);
  MidiState get state => holder.rState;

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
    holder.setDevice(device);
    lpDevice = LaunchpadFactory.create(midi: midi, device: device);
    if (device != null) {      
      await midi.connectToDevice(device);
      // midi.onMidiDataReceived?.listen(_handleMidiMessage);
      lpDevice?.midi.onMidiDataReceived?.listen(_handleMidiMessage);
    }
  }

  void _handleMidiMessage(MidiPacket event) {
    // debug(deps, 'event ${event.data}');
    int coords = event.data[1];
    var pressedPad = lpDevice?.pressedPad(coords);
    debug(deps, '${pressedPad?.name}');
    // Check if change page button pressed
    if (managingPads.contains(pressedPad)) {
      holder.setPage(pressedPad);
    } else {
      var bank = state.banks[state.page]?[pressedPad];
      if (bank != null) {
        bank.trigger();
      }
    }
  }

  void setMode(Set<Mode> modes) => holder.setMode(modes.first);

  Future<void> disconnect() async {
    if (holder.rState.device != null) {
      midi.disconnectDevice(holder.rState.device!);
      holder.setDevice(null);
    }
  }

  void sendSignal(int coords, {bool stop = false}) async {
    if (isConnected) {
      midi.sendData(Uint8List.fromList([144, coords, ColorMk1.green.dark]));
      // for (int i = 0; i <= 127; i++) {
      //   debug(deps, 'velocity: $i, $coords');
      //   await Future.delayed(
      //     const Duration(seconds: 2),
      //     () => {
      //       midi.sendData(Uint8List.fromList([144, coords, i])),
      //     },
      //   );
      // }
    }
  }
}
