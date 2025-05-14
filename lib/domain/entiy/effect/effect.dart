import 'package:lpls/domain/entiy/effect/utils/generate_empty_frame.dart';
import 'package:lpls/domain/enum/brightness.dart';
import 'package:lpls/domain/enum/color_mk1.dart';
import 'package:lpls/domain/enum/color_mk2.dart';
import 'package:lpls/domain/enum/lp_color.dart';
import 'package:lpls/domain/enum/pad.dart';
import 'package:lpls/domain/type/frame.dart';
import 'package:lpls/domain/type/full_color.dart';
import 'package:lpls/utils/bpm_utils.dart';

class Effect<T extends LPColor> {
  final int frameTime;
  final int beats;
  final List<Frame<T>> frames;

  const Effect({
    required this.frameTime,
    required this.frames,
    required this.beats,
  });

  factory Effect.initial() => Effect<T>(frameTime: 500, frames: [], beats: 1);

  Effect<T> copyWith({int? frameTime, List<Frame<T>>? frames, int? beats}) =>
      Effect(
        frameTime: frameTime ?? this.frameTime,
        frames: frames ?? this.frames,
        beats: beats ?? this.beats,
      );

  Effect withPadColored(
    int frameIndex,
    Pad pad,
    FullColor<T>? color,
    FullColor<T> offColor,
  ) {
    if (frameIndex >= frames.length) {
      throw RangeError('Frame $frameIndex does not exist.');
    }

    final newFrames = List<Frame<T>>.from(frames);
    final newFrame = Map<Pad, FullColor<T>>.from(newFrames[frameIndex]);
    newFrame[pad] = color ?? offColor;
    newFrames[frameIndex] = newFrame;

    return copyWith(frames: newFrames);
  }

  Effect<T> withNewFrame() {
    final newFrames = List<Frame<T>>.from(frames); // копируем старые фреймы
    newFrames.add({}); // добавляем новый пустой кадр
    return copyWith(frames: newFrames); // возвращаем новый эффект с тем же T
  }

  Effect<T> withoutFrame(int frameIndex) {
    if (frameIndex < frames.length) {
      final newFrames = List<Frame<T>>.from(frames)..removeAt(frameIndex);
      return copyWith(frames: newFrames);
    }
    return this;
  }

  Effect withBPM(int bpm) {
    return copyWith(frameTime: BpmUtils.bpmToMillis(bpm, beats));
  }
}
