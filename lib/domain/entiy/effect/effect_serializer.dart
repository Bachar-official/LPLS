import 'package:lpls/domain/entiy/effect/effect.dart';
import 'package:lpls/domain/enum/lp_color.dart';

abstract interface class EffectSerializer<T extends LPColor> {
  Effect<T> fromMap(Map<String, dynamic> map);
  Map<String, dynamic> toMap(Effect<T> effect, {required int bpm, required String palette});
  static const bpm = 'bpm';
  static const beats = 'beats';
  static const frames = 'frames';
  static const pads = 'pads';
  static const minuteMillis = 60000;
  static const quarter = 0.25;
  static const pad = 'pad';
  static const color = 'color';
  static const palette = 'palette';
}