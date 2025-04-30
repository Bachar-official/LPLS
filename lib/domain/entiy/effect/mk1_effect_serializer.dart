import 'package:lpls/domain/entiy/effect/effect.dart';
import 'package:lpls/domain/entiy/effect/effect_serializer.dart';
import 'package:lpls/domain/enum/color_mk1.dart';
import 'package:lpls/domain/enum/pad.dart';
import 'package:lpls/domain/type/frame.dart';

class Mk1EffectSerializer implements EffectSerializer<ColorMk1> {
  @override
  Effect<ColorMk1> fromMap(Map<String, dynamic> map) {
    final bpm = map[EffectSerializer.bpm] as int;
    final frameTime = ((EffectSerializer.minuteMillis / bpm) *  EffectSerializer.quarter).round();
    final List<Frame<ColorMk1>> frames = [];

    for (final frame in map[EffectSerializer.frames]) {
      final Frame<ColorMk1> elementFrame = {};
      for (final padEntry in frame[EffectSerializer.pads]) {
        final pad = Pad.values.firstWhere((p) => p.name == padEntry[EffectSerializer.pad]);
        final (color, brightness) = ColorMk1.deserialize(padEntry[EffectSerializer.color]);
        elementFrame[pad] = (color, brightness);
      }
      frames.add(elementFrame);
    }

    return Effect<ColorMk1>(frameTime: frameTime, frames: frames, beats: map[EffectSerializer.beats]);
  }

  @override
  Map<String, dynamic> toMap(Effect<ColorMk1> effect, {required int bpm, required String palette}) {
    return {
      EffectSerializer.bpm: bpm,
      EffectSerializer.palette: 'mk1',
      EffectSerializer.beats: effect.beats,
      EffectSerializer.frames: effect.frames.map((frame) => {
        EffectSerializer.pads: frame.entries.map((entry) {
          final padName = entry.key.name;
          final (color, brightness) = entry.value;
          final colorName = brightness != null
          ? color.serialize(brightness) : color.name;

          return {
            EffectSerializer.pad: padName,
            EffectSerializer.color: colorName,
          };
        }).toList(),
      }).toList(),
    };
  }  
}