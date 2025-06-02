import 'package:lpls/domain/enum/brightness.dart';
import 'package:lpls/domain/enum/lp_color.dart';

enum ColorMk1 implements LPColor {
  off((dark: 0, middle: 0, light: 0)),

  red((dark: 1, middle: 2, light: 3)),

  green((dark: 28, middle: 32, light: 48)),

  orange((dark: 17, middle: 18, light: 19)),

  yellow((dark: 46, middle: 35, light: 51));

  final ({int dark, int middle, int light}) value;

  @override
  int get light => value.light;
  @override
  int get middle => value.middle;
  @override
  int get dark => value.dark;
  @override
  String get colorName => name;
  @override
  ColorMk1 get offColor => off;

  const ColorMk1(this.value);

  String serialize(Btness brightness) => '$name.${brightness.name}';

  static (ColorMk1, Btness?) deserialize(String str) {
  final parts = str.split('.');
  final colorValue = parts[0];
  final btnessValue = parts.length > 1 ? parts[1] : null;

  final brightness = btnessValue != null
      ? Btness.values.firstWhere((b) => b.name == btnessValue, orElse: () => Btness.light)
      : Btness.light;

  final color = ColorMk1.values.firstWhere(
    (c) => c.name == colorValue,
    orElse: () => throw ArgumentError('Unknown color: $colorValue'),
  );

  return (color, brightness);
}

}