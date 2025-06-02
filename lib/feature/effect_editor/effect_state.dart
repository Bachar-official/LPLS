import 'package:lpls/domain/entiy/effect/effect.dart';
import 'package:lpls/domain/enum/effect_instrument.dart';
import 'package:lpls/domain/type/full_color.dart';

class EffectState {
  final Effect? effect;
  final FullColor? selectedColor;
  final int frameNumber;
  final EffectInstrument instrument;

  bool get hasEffect => effect != null;
  bool get isFirstFrame => frameNumber == 0;
  bool get isLastFrame =>
      hasEffect && frameNumber == effect!.frames.length - 1;
  bool get isSingleFrame => effect!.frames.length < 2;

  bool get isRemoveAvailable => hasEffect && !isSingleFrame;
  bool get isControlAvailable => hasEffect;

  const EffectState({
    required this.effect,
    required this.frameNumber,
    required this.selectedColor,
    required this.instrument,
  });

  EffectState.initial() : effect = null, frameNumber = 0, selectedColor = null, instrument = EffectInstrument.brush;

  EffectState copyWith({
    Effect? effect,
    bool nullableEffect = false,
    int? frameNumber,
    FullColor? selectedColor,
    bool nullableColor = false,
    EffectInstrument? instrument,
  }) => EffectState(
    effect: nullableEffect ? null : effect ?? this.effect,
    frameNumber: frameNumber ?? this.frameNumber,
    selectedColor: nullableColor ? null : selectedColor ?? this.selectedColor,
    instrument: instrument ?? this.instrument,
  );
}
