import 'package:flutter/services.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:lpls/domain/enum/brightness.dart';
import 'package:lpls/domain/enum/lp_color.dart';
import 'package:lpls/domain/enum/pad.dart';

abstract class LaunchpadDevice<T extends LPColor> {
  final MidiCommand midi;
  final T palette;
  late final String deviceId;
  late final String name;
  Map<Pad, int> get mapping;

  LaunchpadDevice({required this.midi, required MidiDevice device, required this.palette}) {
    name = device.name;
    deviceId = device.id;
  }

  void sendData(Pad pad, T color, {Btness brightness = Btness.light }) {
    final value = switch(brightness) {
      Btness.dark => color.dark,
      Btness.light => color.light,
      Btness.middle => color.middle,
    };
    midi.sendData(Uint8List.fromList([144, mapping[pad]!, value]), deviceId: deviceId);
  }
}