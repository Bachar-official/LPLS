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

  Effect copyWith({
    int? frameTime,
    List<Frame<T>>? frames,
    int? beats,
  }) => Effect(
    frameTime: frameTime ?? this.frameTime,
    frames: frames ?? this.frames,
    beats: beats ?? this.beats,
  );

  void draw(int frame, Pad pad, FullColor<T> color) {
    if (frame < frames.length) {
      frames[frame][pad] = color;
    } else {
      throw RangeError('Frame $frame does not exist.');
    }
  }
}