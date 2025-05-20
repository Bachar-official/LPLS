import 'dart:convert';
import 'dart:io';

import 'package:lpls/domain/entiy/effect/effect.dart';
import 'package:lpls/domain/entiy/effect/effect_serializer.dart';
import 'package:lpls/domain/entiy/effect/mk1_effect_serializer.dart';
import 'package:lpls/domain/entiy/effect/mk2_effect_serializer.dart';
import 'package:lpls/domain/enum/color_mk1.dart';
import 'package:lpls/domain/enum/color_mk2.dart';
import 'package:lpls/domain/enum/lp_color.dart';
import 'package:lpls/utils/bpm_utils.dart';

class EffectFactory {
  static Future<Effect> readFile(File file) async {
  final content = await file.readAsString();
  return EffectFactory.fromJson(content);
}

  static Effect fromJson(String json) {
    final map = jsonDecode(json);
    final palette = map[EffectSerializer.palette];

    switch(palette) {
      case 'mk1': return Mk1EffectSerializer().fromMap(map);
      case 'mk2': return Mk2EffectSerializer().fromMap(map);
      default: throw UnsupportedError('Unsupported palette: $palette');
    }
  }

  static String toJson<T extends LPColor>(
    Effect<T> effect, {
    required String palette,
  }) {
    final bpm = BpmUtils.millisToBpm(effect.frameTime, effect.beats);
    switch(palette) {
      case 'mk1': return jsonEncode(Mk1EffectSerializer().toMap(effect as Effect<ColorMk1>, bpm: bpm, palette: palette));
      case 'mk2': return jsonEncode(Mk2EffectSerializer().toMap(effect as Effect<ColorMk2>, bpm: bpm, palette: palette));
      default: throw UnsupportedError('Unsupported palette: $palette');
    }
  }
}


