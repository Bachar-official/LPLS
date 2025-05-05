import 'package:lpls/domain/entiy/effect/effect.dart';
import 'package:lpls/domain/enum/lp_color.dart';

class EffectState {
  final Effect effect;
  final int frameNumber;

  bool get isFirstFrame => frameNumber == 0;
  bool get isLastFrame => frameNumber == effect.frames.length - 1;
  bool get isSingleFrame => effect.frames.length == 1;

  const EffectState({required this.effect, required this.frameNumber});

  EffectState.initial() : effect = Effect.initial(), frameNumber = 0;

  EffectState copyWith({Effect? effect, int? frameNumber}) =>
      EffectState(effect: effect ?? this.effect, frameNumber: frameNumber ?? this.frameNumber);
}
