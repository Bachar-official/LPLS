import 'package:lpls/domain/entiy/effect/effect.dart';
import 'package:lpls/domain/entiy/effect/effect_serializer.dart';
import 'package:lpls/domain/enum/color_mk2.dart';
import 'package:lpls/domain/enum/pad.dart';
import 'package:lpls/domain/type/frame.dart';
import 'package:lpls/utils/bpm_utils.dart';

class Mk2EffectSerializer implements EffectSerializer<ColorMk2> {
  @override
  Effect<ColorMk2> fromMap(Map<String, dynamic> map) {
    final bpm = map[EffectSerializer.bpm] as int;
    final frameTime = BpmUtils.bpmToMillis(bpm, map[EffectSerializer.beats]);
    final List<Frame<ColorMk2>> frames = [];

    for (final frame in map[EffectSerializer.frames]) {
      final Frame<ColorMk2> elementFrame = {};
      for (final padEntry in frame[EffectSerializer.pads]) {
        final pad = Pad.values.firstWhere((p) => p.name == padEntry[EffectSerializer.pad]);
        final (color, brightness) = ColorMk2.deserialize(padEntry[EffectSerializer.color]);
        elementFrame[pad] = (color, brightness);
      }
      frames.add(elementFrame);
    }

    return Effect<ColorMk2>(frameTime: frameTime, frames: frames, beats: map[EffectSerializer.beats]);
  }

  @override
  Map<String, dynamic> toMap(Effect<ColorMk2> effect, {required int bpm, required String palette}) {
    return {
      EffectSerializer.bpm: bpm,
      EffectSerializer.palette: 'mk2',
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