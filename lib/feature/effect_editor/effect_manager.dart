import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:lpls/domain/entiy/effect/effect.dart';
import 'package:lpls/domain/entiy/effect/effect_factory.dart';
import 'package:lpls/domain/entiy/effect/effect_serializer.dart';
import 'package:lpls/domain/entiy/effect/mk1_effect_serializer.dart';
import 'package:lpls/domain/entiy/effect/mk2_effect_serializer.dart';
import 'package:lpls/domain/entiy/manager_deps.dart';
import 'package:lpls/domain/enum/brightness.dart';
import 'package:lpls/domain/enum/color_mk1.dart';
import 'package:lpls/domain/enum/color_mk2.dart';
import 'package:lpls/domain/enum/pad.dart';
import 'package:lpls/domain/type/full_color.dart';
import 'package:lpls/feature/effect_editor/effect_holder.dart';
import 'package:lpls/feature/effect_editor/effect_state.dart';
import 'package:lpls/feature/effect_editor/utils/palettes.dart';
import 'package:lpls/feature/home/home_manager.dart';
import 'package:lpls/feature/project/utils/check_file_extension.dart';
import 'package:lpls/utils/bpm_utils.dart';
import 'package:lpls/utils/ui_utils.dart';

class EffectManager {
  final EffectHolder holder;
  final ManagerDeps deps;
  final HomeManager homeManager;
  Timer? _playbackTimer;
  int _currentFrameIndex = 0;
  bool _isPlaying = false;
  Stopwatch? _stopwatch;
  Duration _remainingTime = Duration.zero;

  EffectManager({
    required this.deps,
    required this.holder,
    required this.homeManager,
  });

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
    holder.setFrameNumber(state.effect!.frames.length - 1);
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
        effect?.withPadColored(frame, pad, color, (
          state.effect is Effect<ColorMk1> ? ColorMk1.off : ColorMk2.off,
          null,
        )),
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
    _remainingTime =
        Duration(milliseconds: state.effect!.frameTime) - _stopwatch!.elapsed;
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

    _playbackTimer = Timer.periodic(Duration(milliseconds: frameTime), (timer) {
      if (_currentFrameIndex >= state.effect!.frames.length - 1) {
        _currentFrameIndex = 0; // Зацикливаем
      } else {
        _currentFrameIndex++;
      }
      holder.setFrameNumber(_currentFrameIndex);
      _stopwatch?.reset();
    });

    // Если было восстановление с паузы, устанавливаем задержку
    if (initialDelay != null) {
      _playbackTimer = Timer(initialDelay, () {
        _playbackTimer?.cancel();
        _startPlaybackTimer();
      });
    }
  }

  Future<void> saveEffect() async {
    debug(deps, 'Try to save effect at file');
    try {
      if (state.effect == null) {
        warning(
          deps,
          'Effect is null',
          showScaffold: true,
          scaffoldMessage: 'There is no effect to save',
        );
      } else {
        var path = await FilePicker.platform.saveFile(
          dialogTitle: 'Select output file',
          fileName: FileExtensions.effectFileName,
        );
        if (path == null) {
          warning(
            deps,
            'Cancelled file saving',
            showScaffold: true,
            scaffoldMessage: 'File saving cancelled',
          );
        } else {
          if (state.effect is Effect<ColorMk1>) {
            final map = Mk1EffectSerializer().toMap(
              state.effect as Effect<ColorMk1>,
              bpm: BpmUtils.millisToBpm(
                state.effect?.frameTime ?? 0,
                state.effect?.beats ?? 1,
              ),
              palette: 'mk1',
            );
            await File(path).writeAsString(jsonEncode(map));
          } else {
            final map = Mk2EffectSerializer().toMap(
              state.effect as Effect<ColorMk2>,
              bpm: BpmUtils.millisToBpm(
                state.effect?.frameTime ?? 0,
                state.effect?.beats ?? 1,
              ),
              palette: 'mk2',
            );
            await File(path).writeAsString(jsonEncode(map));
          }
          success(deps, 'File saved at $path');
        }
      }
    } catch (e, s) {
      catchException(deps, e, stackTrace: s);
    }
  }

  Future<void> openEffect() async {
    debug(deps, 'Try to open effect from file');
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: [FileExtensions.effect],
      );
      if (result == null) { 
        warning(deps, 'file pick result is null', showScaffold: true, scaffoldMessage: 'There is no file to open');
      } else {
        final file = File(result.files.first.path!);
        final effect = await EffectFactory.readFile(file);
        holder.setEffect(effect);
        success(deps, 'Effect loaded from file');
      }
    } catch (e, s) {
      catchException(deps, e, stackTrace: s);
    }
  }

  void goBack() => homeManager.toTrackScreen();
}
