import 'package:lpls/domain/entiy/effect/effect.dart';
import 'package:lpls/domain/enum/lp_color.dart';
import 'package:lpls/domain/type/frame.dart';
import 'package:lpls/domain/type/full_color.dart';

abstract interface class GeneratedEffect<T extends LPColor> {
  Effect<T> getEffect(T color);
  Frame<T> getFrame(Frame<T> frame, FullColor<T> color);
}