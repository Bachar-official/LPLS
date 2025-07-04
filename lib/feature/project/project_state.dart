import 'package:lpls/constants/pad_structure.dart';
import 'package:lpls/domain/entiy/launchpad/launchpad_device.dart';
import 'package:lpls/domain/enum/mode.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:lpls/utils/fill_initial_banks.dart';
import 'package:minisound/engine.dart' as minisound;

class ProjectState {
  final MidiDevice? device;
  final LaunchpadDevice? lpDevice;
  final List<MidiDevice> devices;
  final int page;
  final Mode mode;
  final bool isLoading;
  final PadStructure banks;
  final double volume;

  ProjectState({
    required this.device,
    required this.devices,
    required this.page,
    required this.mode,
    required this.isLoading,
    required this.banks,
    required this.lpDevice,
    required this.volume,
  });

  ProjectState.initial(minisound.Engine engine)
    : device = null,
    lpDevice = null,
      devices = [],
      page = 0,
      mode = Mode.audio,
      isLoading = false,
      banks = fillInitialBanks(engine),
      volume = 0.5;

  ProjectState copyWith({
    MidiDevice? device,
    bool nullableDevice = false,
    List<MidiDevice>? devices,
    int? page,
    Mode? mode,
    bool? isLoading,
    PadStructure? banks,
    LaunchpadDevice? lpDevice,
    bool nullableLpDevice = false,
    double? volume,
  }) {
    return ProjectState(
      device: nullableDevice ? null : device ?? this.device,
      devices: devices ?? this.devices,
      page: page ?? this.page,
      mode: mode ?? this.mode,
      isLoading: isLoading ?? this.isLoading,
      banks: banks ?? this.banks,
      lpDevice: nullableLpDevice ? null : lpDevice ?? this.lpDevice,
      volume: volume ?? this.volume,
    );
  }
}
