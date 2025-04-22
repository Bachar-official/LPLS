import 'package:flutter/services.dart';
import 'package:lpls/domain/entiy/manager_deps.dart';
import 'package:lpls/domain/entiy/mode.dart';
import 'package:lpls/feature/MIDI/midi_holder.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:lpls/feature/MIDI/midi_state.dart';
import 'package:lpls/utils/ui_utils.dart';

class MidiManager {
  final MidiHolder holder;
  final ManagerDeps deps;
  final MidiCommand midi = MidiCommand();
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
    if (device != null) {
      await midi.connectToDevice(device);
      midi.onMidiDataReceived?.listen(_handleMidiMessage);
    }
  }

  void _handleMidiMessage(MidiPacket event) {
    int coords = event.data[1];
    deps.logger.d(coords);
    // Check if change page button pressed
    if (coords % 10 == 9 && coords < 100) {
      holder.setPage((89 - coords) ~/ 10);
    } else if (coords < 100) {
      var bank = state.banks[state.page]?[coords];
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

  void sendSignal(int coords, {bool stop = false}) {
    if (isConnected) {
      debug(deps, 'Try to send signal on pad $coords');
      midi.sendData(Uint8List.fromList([144, coords, stop ? 0 : 127, 0]));
    }
  }
}
