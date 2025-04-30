import 'package:lpls/domain/enum/brightness.dart';
import 'package:lpls/domain/enum/lp_color.dart';

enum ColorMk2 implements LPColor {
  off((dark: 0, middle: 0, light: 0)),

  white((dark: 1, middle: 2, light: 3)),

  red((dark: 7, middle: 6, light: 5)),

  orange((dark: 11, middle: 10, light: 9)),

  yellow((dark: 15, middle: 14, light: 13)),

  greenWarm((dark: 19, middle: 18, light: 17)),

  green((dark: 23, middle: 22, light: 21)),

  cyan((dark: 31, middle: 30, light: 29)),

  magenta((dark: 39, middle: 38, light: 37)),

  blue((dark: 47, middle: 46, light: 45));

  final ({int dark, int middle, int light}) value;

  
  const ColorMk2(this.value);
  
  @override
  int get dark => value.dark;
  
  @override
  int get light => value.light;
  
  @override
  int get middle => value.middle;

  String serialize(Btness brightness) => '$name.${brightness.name}';

  static (ColorMk2, Btness?) deserialize(String str) {
    final [colorValue, btnessValue] = str.split('.');
    final brightness = btnessValue.isNotEmpty ? Btness.values.firstWhere((b) => b.name == btnessValue) : Btness.light;
    final color = ColorMk2.values.firstWhere((c) => c.name == colorValue);
    return (color, brightness);
  }
}
