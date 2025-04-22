import 'package:lpls/domain/entiy/mode.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';

class MidiState {
  final MidiDevice? device;
  final List<MidiDevice> devices;
  final int page;
  final Mode mode;
  final bool isLoading;

  MidiState({
    required this.device,
    required this.devices,
    required this.page,
    required this.mode,
    required this.isLoading,
  });

  MidiState.initial() : device = null, devices = [], page = 0, mode = Mode.midi, isLoading = false;

  MidiState copyWith({
    MidiDevice? device,
    bool nullableDevice = false,
    List<MidiDevice>? devices,
    int? page,
    Mode? mode,
    bool? isLoading,
  }) {
    return MidiState(
      device: nullableDevice ? null : device ?? this.device,
      devices: devices ?? this.devices,
      page: page ?? this.page,
      mode: mode ?? this.mode,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
