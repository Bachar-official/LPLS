import 'package:flutter/material.dart';
import 'package:lpls/domain/enum/brightness.dart';
import 'package:lpls/domain/enum/color_mk1.dart';
import 'package:lpls/domain/enum/color_mk2.dart';
import 'package:lpls/domain/enum/lp_color.dart';
import 'package:lpls/domain/type/full_color.dart';

List<FullColor<T>> generatePalette<T extends LPColor>(List<T> values) {
  final result = <FullColor<T>>[];
  for (final color in values.where((val) => val.colorName != 'off').toList()) {
    // for (final btness in Btness.values) {
    //   result.add((color, btness));
    // }
    result.add((color, Btness.light));
  }
  return result;
}

Widget getBtnessIcon<T extends LPColor>(T? color, Btness brightness) {
  const baseColors = {
    ColorMk1.green: Colors.green,
    ColorMk1.orange: Colors.orange,
    ColorMk1.yellow: Colors.yellow,
    ColorMk1.red: Colors.red,

    ColorMk2.white: Colors.white,
    ColorMk2.red: Colors.red,
    ColorMk2.orange: Colors.orange,
    ColorMk2.yellow: Colors.yellow,
    ColorMk2.greenWarm: Color.fromARGB(255, 166, 255, 0),
    ColorMk2.green: Colors.green,
    ColorMk2.aqua: Color.fromARGB(255, 0, 255, 166),
    ColorMk2.cyan: Colors.cyan,
    ColorMk2.sky: Color.fromARGB(255, 0, 200, 255),
    ColorMk2.blue: Colors.blue,
    ColorMk2.indigo: Color.fromARGB(255, 75, 0, 255),
    ColorMk2.purple: Colors.purple,
    ColorMk2.violet: Color.fromARGB(255, 180, 0, 255),
    ColorMk2.magenta: Color.fromARGB(255, 255, 0, 180),
    ColorMk2.fuchsia: Color.fromARGB(255, 255, 0, 120),
    ColorMk2.amber: Colors.amber,
  };
  final baseColor = HSLColor.fromColor(baseColors[color]!);
  final containerColor = switch(brightness) {
    Btness.light => baseColor,
    Btness.middle => baseColor.withLightness((baseColor.lightness * 0.75).clamp(0.0, 1.0)),
    Btness.dark => baseColor.withLightness((baseColor.lightness * 0.5).clamp(0.0, 1.0)),
  };

  return Container(
    width: 30,
    height: 30,
    color: containerColor.toColor(),
  );
}

Color resolveColor<T extends LPColor>(FullColor<T>? color) {
  if (color == null) {
    return Colors.grey.shade400;
  }
  if (color.$1.colorName == 'off') {
    return Colors.black;
  }

  const baseColors = {
    ColorMk1.green: Colors.green,
    ColorMk1.orange: Colors.orange,
    ColorMk1.yellow: Colors.yellow,
    ColorMk1.red: Colors.red,

    ColorMk2.white: Colors.white,
    ColorMk2.red: Colors.red,
    ColorMk2.orange: Colors.orange,
    ColorMk2.yellow: Colors.yellow,
    ColorMk2.greenWarm: Color.fromARGB(255, 166, 255, 0),
    ColorMk2.green: Colors.green,
    ColorMk2.aqua: Color.fromARGB(255, 0, 255, 166),
    ColorMk2.cyan: Colors.cyan,
    ColorMk2.sky: Color.fromARGB(255, 0, 200, 255),
    ColorMk2.blue: Colors.blue,
    ColorMk2.indigo: Color.fromARGB(255, 75, 0, 255),
    ColorMk2.purple: Colors.purple,
    ColorMk2.violet: Color.fromARGB(255, 180, 0, 255),
    ColorMk2.magenta: Color.fromARGB(255, 255, 0, 180),
    ColorMk2.fuchsia: Color.fromARGB(255, 255, 0, 120),
    ColorMk2.amber: Colors.amber,
  };

  final base = baseColors[color.$1]!;

  double factor;
  switch (color.$2) {
    case Btness.dark:
      factor = 0.5;
      break;
    case Btness.middle:
      factor = 0.75;
      break;
    case Btness.light:
    case null:
      return base;
  }

  final hsl = HSLColor.fromColor(base);
  final darkened = hsl.withLightness((hsl.lightness * factor).clamp(0.0, 1.0));
  return darkened.toColor();
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
