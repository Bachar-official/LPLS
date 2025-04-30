import 'package:lpls/domain/entiy/effect/effect.dart';
import 'package:lpls/domain/entiy/effect/generated/generated_effect.dart';
import 'package:lpls/domain/enum/brightness.dart';
import 'package:lpls/domain/enum/lp_color.dart';
import 'package:lpls/domain/enum/pad.dart';
import 'package:lpls/domain/type/frame.dart';

class LineEffect<T extends LPColor> implements GeneratedEffect<T> {
  final Pad from;
  final Pad to;

  const LineEffect({required this.from, required this.to});

  @override
  Effect<T> getEffect(T color) {
    final frames = <Frame<T>>[];
    for(int i = 1; i <= 8; i++) {
      final pad = Pad.values.firstWhere((p) => p.name == 'a$i');
      frames.add({
        pad: (color, Btness.light),
      });
    }
    return Effect<T>(beats: 1, frameTime: 200, frames: frames);
  }
}