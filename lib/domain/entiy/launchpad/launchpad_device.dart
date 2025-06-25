import 'dart:async';
import 'dart:typed_data';
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

  Map<Pad, (T, Btness?)> _globalFrame = {};
  final List<_ActiveEffect<T>> _activeEffects = [];

  Timer? _effectTimer;

  LaunchpadDevice({
    required this.midi,
    required MidiDevice device,
    required this.palette,
  }) {
    name = device.name;
    deviceId = device.id;
  }

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

  void playEffect(Effect<T>? effect) {
    if (effect == null || effect.frames.isEmpty) return;

    _activeEffects.add(_ActiveEffect(effect: effect));
    _startTimer();
  }

  void _startTimer() {
    if (_effectTimer != null) return;

    const tickDuration = Duration(milliseconds: 10); // 10ms tick
    _effectTimer = Timer.periodic(tickDuration, (timer) {
      _onFrameTick(tickDuration.inMilliseconds);
    });

    _onFrameTick(0); // Immediate first update
  }

  void _stopTimer() {
    _effectTimer?.cancel();
    _effectTimer = null;
  }

  void _onFrameTick(int deltaMs) {
    if (_activeEffects.isEmpty) {
      _stopTimer();
      return;
    }

    final completedEffects = <_ActiveEffect<T>>[];
    Map<Pad, (T, Btness?)> combinedEffectsFrame = {};

    for (final active in _activeEffects) {
      active.elapsedMs += deltaMs;

      // Advance frame if enough time passed
      while (
        active.frameIndex < active.effect.frames.length &&
        active.elapsedMs >= active.effect.frameTime
      ) {
        active.elapsedMs -= active.effect.frameTime;
        active.frameIndex++;

        if (active.frameIndex < active.effect.frames.length) {
          active.lastFrame = active.effect.frames[active.frameIndex];
        }
      }

      // Mark effect as done
      if (active.frameIndex >= active.effect.frames.length) {
        completedEffects.add(active);
      } else {
        for (final entry in active.lastFrame.entries) {
          combinedEffectsFrame[entry.key] = entry.value;
        }
      }
    }

    for (final done in completedEffects) {
      _activeEffects.remove(done);
      for (final pad in done.lastFrame.keys) {
        if (!combinedEffectsFrame.containsKey(pad)) {
          _globalFrame.remove(pad);
        }
      }
    }

    // Update global state
    for (final entry in combinedEffectsFrame.entries) {
      _globalFrame[entry.key] = entry.value;
    }

    // Render frame
    _renderFrame(_globalFrame);

    if (_activeEffects.isEmpty && _globalFrame.isEmpty) {
      _stopTimer();
    }
  }

  void _renderFrame(Map<Pad, (T, Btness?)> currentFrame) {
    for (final pad in currentFrame.keys) {
      final (color, btness) = currentFrame[pad]!;
      sendData(pad, color, brightness: btness ?? Btness.light);
    }
  }

  Effect<T> createEffect() => Effect<T>.initial();

  void clearAllPads() {
    for (var pad in Pad.regularPads) {
      sendData(pad, null);
    }
  }
}

class _ActiveEffect<T extends LPColor> {
  final Effect<T> effect;
  int frameIndex = 0;
  int elapsedMs = 0;
  Map<Pad, (T, Btness?)> lastFrame = {};

  _ActiveEffect({required this.effect}) {
    lastFrame = effect.frames[0];
  }
}
