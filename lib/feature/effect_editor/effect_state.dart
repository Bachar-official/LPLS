import 'package:lpls/domain/entiy/effect/effect.dart';
import 'package:lpls/domain/enum/lp_color.dart';

class EffectState {
  final Effect? effect;
  final int frameNumber;

  bool get isFirstFrame => frameNumber == 0;
  bool get isLastFrame => effect != null && frameNumber == effect!.frames.length - 1;
  bool get isSingleFrame => effect != null && effect!.frames.length == 1;

  bool get isRemoveAvailable => effect != null && !isSingleFrame;
  bool get isControlAvailable => effect != null;

  const EffectState({required this.effect, required this.frameNumber});

  EffectState.initial() : effect = null, frameNumber = 0;

  EffectState copyWith({Effect? effect, bool nullableEffect = false, int? frameNumber}) =>
      EffectState(effect: nullableEffect ? null : effect ?? this.effect, frameNumber: frameNumber ?? this.frameNumber);
}
