import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:lpls/constants/pad_structure.dart';
import 'package:lpls/domain/entiy/launchpad/launchpad_device.dart';
import 'package:lpls/utils/fill_initial_banks.dart';

class MobileProjectState {
  final MidiDevice? device;
  final LaunchpadDevice? lpDevice;
  final List<MidiDevice> devices;
  final int page;
  final bool isLoading;
  final PadStructure banks;

  bool get isProjectEmpty => isPadStructureEmpty(banks);

  MobileProjectState({
    required this.banks,
    required this.device,
    required this.devices,
    required this.isLoading,
    required this.lpDevice,
    required this.page,
  });

  MobileProjectState.initial()
    : devices = [],
      banks = fillInitialBanks(),
      device = null,
      lpDevice = null,
      isLoading = false,
      page = 0;

  MobileProjectState copyWith({
    MidiDevice? device,
    bool nullableDevice = false,
    List<MidiDevice>? devices,
    int? page,
    bool? isLoading,
    PadStructure? banks,
    LaunchpadDevice? lpDevice,
    bool nullableLpDevice = false,
  }) => MobileProjectState(
    banks: banks ?? this.banks,
    device: nullableDevice ? null : device ?? this.device,
    devices: devices ?? this.devices,
    isLoading: isLoading ?? this.isLoading,
    lpDevice: lpDevice,
    page: page ?? this.page,
  );
}
