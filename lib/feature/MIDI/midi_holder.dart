import 'package:lpls/domain/entiy/mode.dart';
import 'package:lpls/feature/MIDI/midi_state.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MidiHolder extends StateNotifier<MidiState> {
  MidiHolder() : super(MidiState.initial());

  MidiState get rState => super.state;

  void setDevice(MidiDevice? device) {
    if (device == null) {
      state = state.copyWith(device: null, nullableDevice: true);
    } else {
      state = state.copyWith(device: device);
    }
  }

  void setDevices(List<MidiDevice> devices) {
    state = state.copyWith(devices: devices);
  }

  void setPage(int page) {
    state = state.copyWith(page: page);
  }

  void setMode(Mode mode) {
    state = state.copyWith(mode: mode);
  }

  void setIsLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }
}
