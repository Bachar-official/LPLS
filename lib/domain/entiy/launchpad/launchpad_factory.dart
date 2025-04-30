import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:lpls/domain/entiy/launchpad/launchpad_device.dart';
import 'package:lpls/domain/entiy/launchpad/launchpad_mk1.dart';
import 'package:lpls/domain/entiy/launchpad/launchpad_mk2.dart';
import 'package:lpls/domain/enum/color_mk1.dart';
import 'package:lpls/domain/enum/color_mk2.dart';

class LaunchpadFactory {
  static LaunchpadDevice? create({
    required MidiCommand midi,
    required MidiDevice? device,
  }) {
    if (device == null) {
      return null;
    }
    final name = device.name.toLowerCase();
    if (name.contains('mk2') || name.contains('pro')) {
      return LPMk2(midi: midi, device: device, palette: ColorMk2.values);
    } else if (name.contains(' s') || name.contains('mini')) {
      return LPMk1(midi: midi, device: device, palette: ColorMk1.values);
    }
    return null;
  }
}
