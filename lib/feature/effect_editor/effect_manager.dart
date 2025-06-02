import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:lpls/domain/entiy/entity.dart';
import 'package:lpls/domain/enum/enum.dart';
import 'package:lpls/domain/type/type.dart';

import 'package:lpls/feature/effect_editor/effect_holder.dart';
import 'package:lpls/feature/effect_editor/effect_state.dart';
import 'package:lpls/feature/effect_editor/utils/palettes.dart';
import 'package:lpls/feature/home/home_manager.dart';
import 'package:lpls/feature/project/utils/check_file_extension.dart';

import 'package:lpls/utils/utils.dart';

class EffectManager {
  final EffectHolder holder;
  final ManagerDeps deps;
  final HomeManager homeManager;
  Timer? _playbackTimer;
  int _currentFrameIndex = 0;
  bool isPlaying = false;
  Stopwatch? _stopwatch;
  Duration _remainingTime = Duration.zero;

  EffectManager({
    required this.deps,
    required this.holder,
    required this.homeManager,
  });

  EffectState get state => holder.rState;
  bool get isFramesEmpty => state.effect?.frames.isEmpty ?? false;
  FullColor get offColor =>
      state.effect is Effect<ColorMk1>
          ? (ColorMk1.off, null)
          : (ColorMk2.off, null);

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
    if (!state.hasEffect) {
      return null;
    }
    return BpmUtils.millisToBpm(state.effect!.frameTime, state.effect!.beats);
  }

  num? getBeats() {
    if (!state.hasEffect) {
      return null;
    }
    return state.effect!.beats;
  }

  String formatBPM(num? value) {
    if (value == null) {
      return 'No effect';
    }
    return '$value BPM';
  }

  void setBPM(num? value) {
    if (value != null && state.hasEffect) {
      holder.setEffect(state.effect?.withBPM(value.toInt()));
    }
  }

  void setBeats(num? value) {
    if (value != null && state.hasEffect) {
      final currentBpm = BpmUtils.millisToBpm(
        state.effect!.frameTime,
        state.effect!.beats,
      );

      holder.setEffect(state.effect?.withBeats(value.toInt(), bpm: currentBpm));
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
    if (state.hasEffect && frame < state.effect!.frames.length) {
      holder.setFrameNumber(frame + 1);
    }
  }

  void goToFirstFrame() {
    holder.setFrameNumber(0);
  }

  void goToLastFrame() {
    if (state.hasEffect) {
      holder.setFrameNumber(state.effect!.frames.length - 1);
    }
  }

  void draw(Pad pad, int frame, FullColor? color) {
    if (state.hasEffect && state.effect!.frames.length >= frame - 1) {
      final effect = state.effect;
      holder.setEffect(effect?.withPadColored(frame, pad, color));
    }
  }

  void pickColor(Pad pad, int frame) {
    if (state.hasEffect && state.effect!.frames.isNotEmpty) {
      selectColor(state.effect!.frames[frame][pad]);
    }
  }

  void selectColor(FullColor? color) {
    holder.setSelectedColor(color);
  }

  void goToFrame(int frame) {
    holder.setFrameNumber(frame.clamp(0, state.effect!.frames.length - 1));
  }

  void play() {
    if (!state.hasEffect || isPlaying) return;

    if (_remainingTime != Duration.zero) {
      resume();
    } else {
      isPlaying = true;
      _currentFrameIndex = state.frameNumber;
      _startPlaybackTimer();
    }
  }

  void pause() {
    if (!isPlaying || _playbackTimer == null) return;

    _playbackTimer?.cancel();
    _remainingTime =
        Duration(milliseconds: state.effect!.frameTime) - _stopwatch!.elapsed;
    _stopwatch?.stop();
    isPlaying = false;
  }

  void resume() {
    if (isPlaying || !state.hasEffect) return;

    isPlaying = true;
    _startPlaybackTimer(initialDelay: _remainingTime);
  }

  void stop() {
    _playbackTimer?.cancel();
    _stopwatch?.stop();
    isPlaying = false;
    _remainingTime = Duration.zero;
    _currentFrameIndex = 0;
    holder.setFrameNumber(0);
  }

  void _startPlaybackTimer({Duration? initialDelay}) {
    if (state.effect == null) return;

    final frameTime = state.effect!.frameTime;
    _stopwatch = Stopwatch()..start();

    _playbackTimer = Timer.periodic(Duration(milliseconds: frameTime), (timer) {
      if (_currentFrameIndex >= state.effect!.frames.length - 1) {
        _currentFrameIndex = 0;
      } else {
        _currentFrameIndex++;
      }
      holder.setFrameNumber(_currentFrameIndex);
      _stopwatch?.reset();
    });

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
        warning(
          deps,
          'file pick result is null',
          scaffoldMessage: 'There is no file to open',
        );
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

  void setInstrument(Set<EffectInstrument> instruments) =>
      holder.setInstrument(instruments.first);

  void clearEffect() {
    if (state.hasEffect) {
      if (state.effect is Effect<ColorMk1>) {
        holder.setEffect(Effect<ColorMk1>.initial());
      } else {
        holder.setEffect(Effect<ColorMk2>.initial());
      }
    }
  }

  void floodfill(Pad pad, int frame, {isErase = false}) {
    if (!state.hasEffect ||
        state.effect!.frames.isEmpty ||
        state.selectedColor == null) {
      return;
    }

    final effect = state.effect!;
    final currentColor = effect.frames[frame][pad];
    final selectedColor = isErase ? null : state.selectedColor;
    if (currentColor == selectedColor) {
      return;
    }

    if (effect is Effect<ColorMk1>) {
      _floodfillImpl<ColorMk1>(effect as Effect<ColorMk1>, pad, frame, isErase: isErase);
    } else if (effect is Effect<ColorMk2>) {
      _floodfillImpl<ColorMk2>(effect as Effect<ColorMk2>, pad, frame, isErase: isErase);
    }
  }

  void _floodfillImpl<T extends LPColor>(Effect<T> effect, Pad pad, int frame, {isErase = false}) {
    final currentColor = effect.frames[frame][pad];
    final offColor = T is ColorMk1 ? (ColorMk1.off, null) as FullColor<T> : (ColorMk2.off, null) as FullColor<T>;
    final selectedColor = isErase ? offColor : state.selectedColor as FullColor<T>?;

    if (selectedColor == null || currentColor == selectedColor) {
      return;
    }

    final frames = List<Frame<T>>.from(effect.frames);
    final currentFrame = Map<Pad, FullColor<T>>.from(frames[frame]);

    final queue = Queue<Pad>();
    final visited = <Pad>{};

    queue.add(pad);
    visited.add(pad);

    while (queue.isNotEmpty) {
      final currentPad = queue.removeFirst();
      currentFrame[currentPad] = selectedColor;

      for (final neighbor in currentPad.neighbors) {
        if (!visited.contains(neighbor) &&
            currentFrame[neighbor] == currentColor) {
          visited.add(neighbor);
          queue.add(neighbor);
        }
      }
    }

    frames[frame] = currentFrame;
    holder.setEffect(effect.copyWith(frames: frames));
  }

  void shiftFrame(Direction direction) {
    debug(deps, 'Trying to shift current frame to ${direction.name}');
    if (state.hasEffect) {
      holder.setEffect(state.effect!.shift(state.frameNumber, direction));
    }
  }
}
