import 'package:lpls/domain/entiy/effect/effect.dart';
import 'package:lpls/domain/entiy/manager_deps.dart';
import 'package:lpls/domain/enum/pad.dart';
import 'package:lpls/domain/type/full_color.dart';
import 'package:lpls/feature/effect_editor/effect_holder.dart';
import 'package:lpls/feature/effect_editor/effect_state.dart';

class EffectManager {
  final EffectHolder holder;
  final ManagerDeps deps;

  EffectManager({required this.deps, required this.holder});

  EffectState get state => holder.rState;

  void setEffect(Effect effect) {
    holder.setEffect(effect);
  }

  void addFrame() {
    if (state.effect == null) {
      holder.setEffect(Effect.initial());
      holder.setFrameNumber(0);
    } else {
      holder.setEffect(state.effect?.withNewFrame());
      holder.setFrameNumber(state.frameNumber + 1);
    }
  }

  void removeFrame() {
    holder.setEffect(state.effect?.withoutFrame(state.frameNumber));
  }

  void goToPrevFrame() {
    final frame = state.frameNumber;
    if (frame != 0) {
      holder.setFrameNumber(frame - 1);
    }
  }

  void goToNextFrame() {
    final frame = state.frameNumber;
    if (state.effect != null && frame < state.effect!.frames.length) {
      holder.setFrameNumber(frame + 1);
    }
  }

  void goToFirstFrame() {
    holder.setFrameNumber(0);
  }

  void goToLastFrame() {
    if (state.effect != null) {
      holder.setFrameNumber(state.effect!.frames.length - 1);
    }
  }

  void draw(Pad pad, int frame, FullColor color) {
    if (state.effect != null && state.effect!.frames.length >= frame - 1) {
      final effect = state.effect;
      holder.setEffect(effect?.withPadColored(frame, pad, color));
    }
  }
}
