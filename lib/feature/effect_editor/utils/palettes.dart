import 'package:flutter/material.dart';
import 'package:lpls/domain/enum/brightness.dart';
import 'package:lpls/domain/enum/color_mk1.dart';
import 'package:lpls/domain/enum/color_mk2.dart';
import 'package:lpls/domain/enum/lp_color.dart';
import 'package:lpls/domain/type/full_color.dart';

List<FullColor<T>> generatePalette<T extends LPColor>(List<T> values) {
  final result = <FullColor<T>>[];
  for (final color in values) {
    for (final btness in Btness.values) {
      result.add((color, btness));
    }
  }
  return result;
}

Color resolveColor<T extends LPColor>(FullColor<T> color) {
  const baseColors = {
    ColorMk1.off: Colors.black,
    ColorMk2.off: Colors.black,

    ColorMk1.green: Colors.green,
    ColorMk1.orange: Colors.orange,
    ColorMk1.yellow: Colors.yellow,
    ColorMk1.red: Colors.red,

    ColorMk2.white: Colors.white,
    ColorMk2.blue: Colors.blue,
    ColorMk2.green: Colors.green,
    ColorMk2.red: Colors.red,
    ColorMk2.yellow: Colors.yellow,
    ColorMk2.cyan: Colors.cyan,
    ColorMk2.greenWarm: Color.fromARGB(255, 166, 255, 0),
    ColorMk2.magenta: Colors.purple,
    ColorMk2.orange: Colors.orange,
  };

  final base = baseColors[color.$1]!;

  switch (color.$2) {
    case Btness.dark: return base.withValues(alpha: 0.5);
    case Btness.middle: return base.withValues(alpha: 0.75);
    case Btness.light: case null: return base;
  }
}

Map<FullColor<T>, Color> buildColorMap<T extends LPColor>(List<T> values) {
  final map = <FullColor<T>, Color>{};
  for (final color in values) {
    for (final btness in Btness.values) {
      final fullColor = (color, btness);
      map[fullColor] = resolveColor(fullColor);
    }
  }
  return map;
}