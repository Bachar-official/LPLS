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

  const ColorMk1(this.value);
}