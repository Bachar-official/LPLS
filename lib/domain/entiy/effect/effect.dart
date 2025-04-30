import 'package:lpls/domain/enum/lp_color.dart';
import 'package:lpls/domain/enum/pad.dart';

class Effect<T extends LPColor> {
  final int frameTime;
  final List<Map<Pad, T>> frames;

  const Effect({
    required this.frameTime,
    required this.frames,
  });

  Effect copyWith({
    int? frameTime,
    T? palette,
    List<Map<Pad, T>>? frames,
  }) => Effect(
    frameTime: frameTime ?? this.frameTime,
    frames: frames ?? this.frames,
  );

  void draw(int frame, Pad pad, T color) {
    if (frame < frames.length) {
      frames[frame][pad] = color;
    } else {
      throw RangeError('Frame $frame does not exist.');
    }
  }
}