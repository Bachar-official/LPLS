import 'package:lpls/domain/entiy/effect/effect.dart';
import 'package:lpls/domain/type/full_color.dart';

class EffectState {
  final Effect? effect;
  final FullColor? selectedColor;
  final int frameNumber;

  bool get isFirstFrame => frameNumber == 0;
  bool get isLastFrame =>
      effect != null && frameNumber == effect!.frames.length - 1;
  bool get isSingleFrame => effect!.frames.length < 2;

  bool get isRemoveAvailable => effect != null && !isSingleFrame;
  bool get isControlAvailable => effect != null;

  const EffectState({
    required this.effect,
    required this.frameNumber,
    required this.selectedColor,
  });

  EffectState.initial() : effect = null, frameNumber = 0, selectedColor = null;

  EffectState copyWith({
    Effect? effect,
    bool nullableEffect = false,
    int? frameNumber,
    FullColor? selectedColor,
    bool nullableColor = false,
  }) => EffectState(
    effect: nullableEffect ? null : effect ?? this.effect,
    frameNumber: frameNumber ?? this.frameNumber,
    selectedColor: nullableColor ? null : selectedColor ?? this.selectedColor,
  );
}
