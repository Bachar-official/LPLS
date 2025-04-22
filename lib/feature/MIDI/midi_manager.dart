import 'package:lpls/domain/entiy/manager_deps.dart';
import 'package:lpls/domain/entiy/mode.dart';
import 'package:lpls/feature/MIDI/midi_holder.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:lpls/utils/ui_utils.dart';

class MidiManager {
  final MidiHolder holder;
  final ManagerDeps deps;
  final MidiCommand midi = MidiCommand();
  bool get isConnected => holder.rState.device != null;

  MidiManager({required this.holder, required this.deps});

  void setLoading(bool isLoading) => holder.setIsLoading(isLoading);

  Future<void> getDevices() async {
    await disconnect();
    setLoading(true);
    try {
      debug(deps, 'Try to get MIDI devices list');
      final devices = await midi.devices ?? [];
      holder.setDevices(devices);
      success(deps, 'Got ${devices.length} devices');
    } catch(e, s) {
      catchException(deps, e, stackTrace: s, description: 'Error while getting MIDI devices list: ');
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
    }
  }

  void setMode(Set<Mode> modes) => holder.setMode(modes.first);

  Future<void> disconnect() async {
    if (holder.rState.device != null) {
      midi.disconnectDevice(holder.rState.device!);
      holder.setDevice(null);
    }
  }
}
