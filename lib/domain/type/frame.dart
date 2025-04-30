import 'package:lpls/domain/enum/lp_color.dart';
import 'package:lpls/domain/enum/pad.dart';
import 'package:lpls/domain/type/full_color.dart';

typedef Frame<T extends LPColor> = Map<Pad, FullColor<T>>;