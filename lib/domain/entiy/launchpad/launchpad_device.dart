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

  /// Returns pad by it coords
  Pad pressedPad(int coords) {
    return mapping.entries.firstWhere((entry) => entry.value == coords).key;
  }

  /// Sends command to Launchpad from color and brightness
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
    _startTimer(effect.frameTime);
  }

  void _startTimer(int frameTime) {
    if (_effectTimer != null) return;

    _effectTimer = Timer.periodic(
      Duration(milliseconds: frameTime),
      (_) => _onFrameTick(),
    );

    _onFrameTick();
  }

  void _stopTimer() {
    _effectTimer?.cancel();
    _effectTimer = null;
  }

  void _onFrameTick() {
    if (_activeEffects.isEmpty) {
      _stopTimer();
      return;
    }

    final completedEffects = <_ActiveEffect<T>>[];
    Map<Pad, (T, Btness?)> combinedEffectsFrame = {};

    for (final active in _activeEffects) {
      if (active.frameIndex < active.effect.frames.length) {
        active.lastFrame = active.effect.frames[active.frameIndex];
        active.frameIndex++;
      }

      if (active.frameIndex >= active.effect.frames.length) {
        completedEffects.add(active);
      }

      for (final entry in active.lastFrame.entries) {
        combinedEffectsFrame[entry.key] = entry.value;
      }
    }

    for (final done in completedEffects) {
      _activeEffects.remove(done);

      // Remove donw frames from global state
      for (final pad in done.lastFrame.keys) {
        if (!combinedEffectsFrame.containsKey(pad)) {
          _globalFrame.remove(pad);
        }
      }
    }

    // Updating global state
    for (final entry in combinedEffectsFrame.entries) {
      _globalFrame[entry.key] = entry.value;
    }

    // Rendering
    _renderFrame(_globalFrame);

    if (_activeEffects.isEmpty && _globalFrame.isEmpty) {
      _stopTimer();
    }
  }

  /// Rendering according to previous state
  void _renderFrame(Map<Pad, (T, Btness?)> currentFrame) {
    final currentPads = currentFrame.keys.toSet();


    for (final pad in currentPads) {
      final (color, btness) = currentFrame[pad]!;
      sendData(pad, color, brightness: btness ?? Btness.light);
    }

  }

  Effect<T> createEffect() => Effect<T>.initial();

  void clearAllPads() {
    for (var pad in Pad.regularPads) {
      sendData(pad, null); // Note On + 0
    }
  }
}

class _ActiveEffect<T extends LPColor> {
  final Effect<T> effect;
  int frameIndex = 0;

  Map<Pad, (T, Btness?)> lastFrame = {};

  _ActiveEffect({required this.effect});
}
