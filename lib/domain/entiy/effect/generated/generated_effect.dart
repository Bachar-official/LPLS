import 'package:lpls/domain/entiy/effect/effect.dart';
import 'package:lpls/domain/enum/lp_color.dart';

abstract interface class GeneratedEffect<T extends LPColor> {
  Effect<T> getEffect(T color);
}