import 'package:lpls/domain/entiy/launchpad/launchpad_device.dart';
import 'package:lpls/domain/enum/color_mk2.dart';
import 'package:lpls/domain/enum/pad.dart';

class LPMiniMk3 extends LaunchpadDevice<ColorMk2> {
  LPMiniMk3({required super.midi, required super.device, required super.palette});

  @override
  String toString() => 'Launchpad Mini Mk3';

  @override
  Map<Pad, int> get mapping => {
    Pad.a1: 64,
    Pad.a2: 65,
    Pad.a3: 66,
    Pad.a4: 67,
    Pad.a5: 96,
    Pad.a6: 97,
    Pad.a7: 98,
    Pad.a8: 99,
    Pad.a: 100,
    Pad.b1: 60,
    Pad.b2: 61,
    Pad.b3: 62,
    Pad.b4: 63,
    Pad.b5: 92,
    Pad.b6: 93,
    Pad.b7: 94,
    Pad.b8: 95,
    Pad.b: 101,
    Pad.c1: 56,
    Pad.c2: 57,
    Pad.c3: 58,
    Pad.c4: 59,
    Pad.c5: 88,
    Pad.c6: 89,
    Pad.c7: 90,
    Pad.c8: 91,
    Pad.c: 102,
    Pad.d1: 52,
    Pad.d2: 53,
    Pad.d3: 54,
    Pad.d4: 55,
    Pad.d5: 84,
    Pad.d6: 85,
    Pad.d7: 86,
    Pad.d8: 87,
    Pad.d: 103,
    Pad.e1: 48,
    Pad.e2: 49,
    Pad.e3: 50,
    Pad.e4: 51,
    Pad.e5: 80,
    Pad.e6: 81,
    Pad.e7: 82,
    Pad.e8: 83,
    Pad.e: 104,
    Pad.f1: 44,
    Pad.f2: 45,
    Pad.f3: 46,
    Pad.f4: 47,
    Pad.f5: 76,
    Pad.f6: 77,
    Pad.f7: 78,
    Pad.f8: 79,
    Pad.f: 105,
    Pad.g1: 40,
    Pad.g2: 41,
    Pad.g3: 42,
    Pad.g4: 43,
    Pad.g5: 72,
    Pad.g6: 73,
    Pad.g7: 74,
    Pad.g8: 75,
    Pad.g: 106,
    Pad.h1: 36,
    Pad.h2: 37,
    Pad.h3: 38,
    Pad.h4: 39,
    Pad.h5: 68,
    Pad.h6: 69,
    Pad.h7: 70,
    Pad.h8: 71,
    Pad.h: 107,
  };
}