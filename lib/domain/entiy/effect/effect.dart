import 'package:lpls/domain/entiy/effect/utils/generate_empty_frame.dart';
import 'package:lpls/domain/enum/brightness.dart';
import 'package:lpls/domain/enum/color_mk1.dart';
import 'package:lpls/domain/enum/color_mk2.dart';
import 'package:lpls/domain/enum/lp_color.dart';
import 'package:lpls/domain/enum/pad.dart';
import 'package:lpls/domain/type/frame.dart';
import 'package:lpls/domain/type/full_color.dart';

class Effect<T extends LPColor> {
  final int frameTime;
  final int beats;
  final List<Frame<T>> frames;

  const Effect({
    required this.frameTime,
    required this.frames,
    required this.beats,
  });

  Effect.initial(): frameTime = 500, beats = 1, frames = [];

  Effect copyWith({int? frameTime, List<Frame<T>>? frames, int? beats}) =>
      Effect(
        frameTime: frameTime ?? this.frameTime,
        frames: frames ?? this.frames,
        beats: beats ?? this.beats,
      );

  Effect withPadColored(int frameIndex, Pad pad, FullColor<T>? color, FullColor<T> offColor) {
    if (frameIndex >= frames.length) {
      throw RangeError('Frame $frameIndex does not exist.');
    }

    final newFrames = List<Frame<T>>.from(frames);
    final newFrame = Map<Pad, FullColor<T>>.from(newFrames[frameIndex]);
    newFrame[pad] = color ?? offColor;
    newFrames[frameIndex] = newFrame;

    return copyWith(frames: newFrames);
  }

  Effect withNewFrame() {
    final Map<Pad, (T, Btness?)> newFrame = {};
    frames.add(newFrame);
    return copyWith(frames: frames);
  }

  Effect withoutFrame(int frameIndex) {
    if (frameIndex < frames.length) {
      frames.removeAt(frameIndex);
      return copyWith(frames: frames);
    }
    return this;
  }
}
