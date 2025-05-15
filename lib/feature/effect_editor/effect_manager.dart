import 'dart:async';

import 'package:lpls/domain/entiy/effect/effect.dart';
import 'package:lpls/domain/entiy/manager_deps.dart';
import 'package:lpls/domain/enum/brightness.dart';
import 'package:lpls/domain/enum/color_mk1.dart';
import 'package:lpls/domain/enum/color_mk2.dart';
import 'package:lpls/domain/enum/pad.dart';
import 'package:lpls/domain/type/full_color.dart';
import 'package:lpls/feature/effect_editor/effect_holder.dart';
import 'package:lpls/feature/effect_editor/effect_state.dart';
import 'package:lpls/feature/effect_editor/utils/palettes.dart';
import 'package:lpls/utils/bpm_utils.dart';
import 'package:lpls/utils/ui_utils.dart';

class EffectManager {
  final EffectHolder holder;
  final ManagerDeps deps;
  Timer? _playbackTimer;
  int _currentFrameIndex = 0;
  bool _isPlaying = false;
  Stopwatch? _stopwatch;
  Duration _remainingTime = Duration.zero;

  EffectManager({required this.deps, required this.holder});
  

  EffectState get state => holder.rState;
  bool get isFramesEmpty => state.effect?.frames.isEmpty ?? false;

  List<FullColor> get generatedPalette {
    if (state.effect is Effect<ColorMk1>) {
      return generatePalette(ColorMk1.values);
    } else if (state.effect is Effect<ColorMk2>) {
      return generatePalette(ColorMk2.values);
    } else {
      return [];
    }
  }

  num? getBPMValue() {
    if (state.effect == null) {
      return null;
    }
    return BpmUtils.millisToBpm(state.effect!.frameTime, state.effect!.beats);
  }

  String formatBPM(num? value) {
    if (value == null) {
      return 'No effect';
    }
    return '$value BPM';
  }

  void setBPM(num? value) {
    if (value != null && state.effect != null) {
      holder.setEffect(state.effect?.withBPM(value.toInt()));
    }
  }

  void setEffect(Effect effect) {
    holder.setEffect(effect);
    debug(deps, 'Set effect to ${state.effect.runtimeType}');
  }

  void addFrame() {
    debug(deps, generatedPalette.length.toString());
    if (state.effect == null) {
      holder.setEffect(Effect.initial().withNewFrame());
      holder.setFrameNumber(0);
    } else {
      holder.setEffect(state.effect?.withNewFrame());
        holder.setFrameNumber(state.effect!.frames.length - 1);
    }
  }

  void removeFrame() {
    holder.setEffect(state.effect?.withoutFrame(state.frameNumber));
  }

  void goToPrevFrame() {
    final frame = state.frameNumber;
    if (frame != 0) {
      holder.setFrameNumber(frame - 1);
    }
  }

  void goToNextFrame() {
    final frame = state.frameNumber;
    if (state.effect != null && frame < state.effect!.frames.length) {
      holder.setFrameNumber(frame + 1);
    }
  }

  void goToFirstFrame() {
    holder.setFrameNumber(0);
  }

  void goToLastFrame() {
    if (state.effect != null) {
      holder.setFrameNumber(state.effect!.frames.length - 1);
    }
  }

  void draw(Pad pad, int frame, FullColor? color) {
    if (state.effect != null && state.effect!.frames.length >= frame - 1) {
      final effect = state.effect;
      holder.setEffect(
        effect?.withPadColored(frame, pad, color, (state.effect is Effect<ColorMk1> ? ColorMk1.off : ColorMk2.off, null)),
      );
    }
  }

  void selectColor(FullColor? color) {
    holder.setSelectedColor(color);
  }

  void goToFrame(int frame) {
    holder.setFrameNumber(frame.clamp(0, state.effect!.frames.length - 1));
  }

  /// Запускает воспроизведение эффекта.
  void play() {
    if (state.effect == null || _isPlaying) return;

    _isPlaying = true;
    _currentFrameIndex = state.frameNumber;
    _startPlaybackTimer();
  }

  /// Ставит воспроизведение на паузу.
  void pause() {
    if (!_isPlaying || _playbackTimer == null) return;

    _playbackTimer?.cancel();
    _remainingTime = Duration(milliseconds: state.effect!.frameTime) - _stopwatch!.elapsed;
    _stopwatch?.stop();
    _isPlaying = false;
  }

  /// Возобновляет воспроизведение с места паузы.
  void resume() {
    if (_isPlaying || state.effect == null) return;

    _isPlaying = true;
    _startPlaybackTimer(initialDelay: _remainingTime);
  }

  /// Останавливает воспроизведение и сбрасывает позицию.
  void stop() {
    _playbackTimer?.cancel();
    _stopwatch?.stop();
    _isPlaying = false;
    _remainingTime = Duration.zero;
    _currentFrameIndex = 0;
    holder.setFrameNumber(0);
  }

  /// Запускает таймер для переключения кадров.
  void _startPlaybackTimer({Duration? initialDelay}) {
    if (state.effect == null) return;

    final frameTime = state.effect!.frameTime;
    _stopwatch = Stopwatch()..start();

    _playbackTimer = Timer.periodic(
      Duration(milliseconds: frameTime),
      (timer) {
        if (_currentFrameIndex >= state.effect!.frames.length - 1) {
          _currentFrameIndex = 0; // Зацикливаем
        } else {
          _currentFrameIndex++;
        }
        holder.setFrameNumber(_currentFrameIndex);
        _stopwatch?.reset();
      },
    );

    // Если было восстановление с паузы, устанавливаем задержку
    if (initialDelay != null) {
      _playbackTimer = Timer(initialDelay, () {
        _playbackTimer?.cancel();
        _startPlaybackTimer();
      });
    }
  }
}
