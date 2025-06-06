import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lpls/domain/entiy/effect/effect.dart';
import 'package:lpls/domain/enum/effect_instrument.dart';
import 'package:lpls/domain/type/full_color.dart';
import 'package:lpls/feature/effect_editor/effect_state.dart';

class EffectHolder extends StateNotifier<EffectState> {
  EffectHolder(): super(EffectState.initial());

  EffectState get rState => state;

  void setEffect(Effect? effect) {
    state = state.copyWith(effect: effect, nullableEffect: effect == null);
  }

  void setFrameNumber(int frameNumber) {
    state = state.copyWith(frameNumber: frameNumber);
  }

  void setSelectedColor(FullColor? selectedColor) {
    state = state.copyWith(selectedColor: selectedColor, nullableColor: selectedColor == null);
  }

  void setInstrument(EffectInstrument instrument) {
    state = state.copyWith(instrument: instrument);
  }

  void setFromTrackEditor(bool fromTrackEditor) {
    state = state.copyWith(fromTrackEditor: fromTrackEditor);
  }
}