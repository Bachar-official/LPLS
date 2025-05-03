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
    final fromCoords = from.coordinates;
    final toCoords = to.coordinates;
    if (toCoords == null || fromCoords == null) {
      return Effect<T>(frameTime: 1, frames: frames, beats: 1);
    }

    int x0 = fromCoords.x;
    int y0 = fromCoords.y;
    int x1 = toCoords.x;
    int y1 = toCoords.y;

    final dx = (x1 - x0).abs();
    final dy = (y1 - y0).abs();
    final sx = x0 < x1 ? 1 : -1;
    final sy = y0 < y1 ? 1 : -1;

    int err = dx - dy;

    while (true) {
      final pad = Pad.fromCoordinates(x: x0, y: y0);
      if (pad != null) frames.add({pad: (color, Btness.light)});
      if (x0 == x1 && y0 == y1) break;

      final e2 = 2 * err;
      if (e2 > -dy) {
        err -= dy;
        x0 += sx;
      }
      if (e2 < dx) {
        err += dx;
        y0 += sy;
      }
    }

    return Effect<T>(beats: 1, frameTime: 200, frames: frames);
  }
}
