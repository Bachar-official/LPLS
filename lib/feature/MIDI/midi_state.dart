import 'package:flutter_application_1/domain/entiy/mode.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';

class MidiState {
  final MidiDevice? device;
  final List<MidiDevice> devices;
  final int page;
  final Mode mode;

  MidiState({
    required this.device,
    required this.devices,
    required this.page,
    required this.mode,
  });

  MidiState.initial() : device = null, devices = [], page = 0, mode = Mode.midi;

  MidiState copyWith({
    MidiDevice? device,
    bool nullableDevice = false,
    List<MidiDevice>? devices,
    int? page,
    Mode? mode,
  }) {
    return MidiState(
      device: nullableDevice ? null : device ?? this.device,
      devices: devices ?? this.devices,
      page: page ?? this.page,
      mode: mode ?? this.mode,
    );
  }
}
