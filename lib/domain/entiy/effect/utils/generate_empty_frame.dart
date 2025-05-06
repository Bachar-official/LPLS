import 'package:lpls/domain/enum/brightness.dart';
import 'package:lpls/domain/enum/color_mk1.dart';
import 'package:lpls/domain/enum/color_mk2.dart';
import 'package:lpls/domain/enum/lp_color.dart';
import 'package:lpls/domain/enum/pad.dart';
import 'package:lpls/domain/type/frame.dart';

Frame generateEmptyFrame<T extends LPColor>(T color) {
  if (T is ColorMk1) {
    Frame<ColorMk1> result = {};
    for (var pad in Pad.regularPads) {
      result[pad] = (ColorMk1.off, Btness.dark);
    }
    return result;
  }
  Frame<ColorMk2> result = {};
  for (var pad in Pad.regularPads) {
    result[pad] = (ColorMk2.off, Btness.dark);
  }
  return result;
}
