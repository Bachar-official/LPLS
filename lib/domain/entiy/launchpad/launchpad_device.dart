import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:lpls/domain/entiy/effect/effect.dart';
import 'package:lpls/domain/enum/brightness.dart';
import 'package:lpls/domain/enum/lp_color.dart';
import 'package:lpls/domain/enum/pad.dart';

abstract class LaunchpadDevice<T extends LPColor> {
  final MidiCommand midi;
  final List<T> palette;
  late final String deviceId;
  late final String name;
  Map<Pad, int> get mapping;

  LaunchpadDevice({
    required this.midi,
    required MidiDevice device,
    required this.palette,
  }) {
    name = device.name;
    deviceId = device.id;
  }

  Effect<T> createEffect() => Effect<T>.initial();

  Pad pressedPad(int coords) {
    return mapping.entries.firstWhere((entry) => entry.value == coords).key;
  }

  void sendData(Pad pad, T? color, {Btness brightness = Btness.light}) {
    final value = switch (brightness) {
      Btness.dark => color?.dark,
      Btness.light => color?.light,
      Btness.middle => color?.middle,
    };
    midi.sendData(
      Uint8List.fromList([144, mapping[pad]!, value ?? 0]),
      deviceId: deviceId,
    );
  }

  void sendCheckSignal(Pad pad, {bool stop = false}) {
    midi.sendData(
      Uint8List.fromList([144, mapping[pad]!, stop ? 0 : 127]),
      deviceId: deviceId,
    );
  }

  Future<void> playEffect(Effect<T> effect) async {
  if (effect.frames.isEmpty) return;

  Map<Pad, (T, Btness?)> previousFrame = {};

  void renderFrame(Map<Pad, (T, Btness?)> currentFrame) {
    // Пэды, которые были, но теперь отсутствуют — очистить
    for (var pad in previousFrame.keys) {
      if (!currentFrame.containsKey(pad)) {
        sendData(pad, null, brightness: Btness.light);
      }
    }

    // Отрисовать текущие пэды
    for (var entry in currentFrame.entries) {
      var (color, btness) = entry.value;
      sendData(entry.key, color, brightness: btness ?? Btness.light);
    }

    previousFrame = currentFrame;
  }

  // Отрисовать первый кадр
  renderFrame(effect.frames.first);

  int index = 1;
  Timer.periodic(Duration(milliseconds: effect.frameTime), (timer) {
    if (index >= effect.frames.length) {
      timer.cancel();
      // Очистить всё, что было в последнем кадре
      for (var pad in previousFrame.keys) {
        sendData(pad, null, brightness: Btness.light);
      }
      return;
    }

    final frame = effect.frames[index];
    renderFrame(frame);
    index++;
  });
}

}
