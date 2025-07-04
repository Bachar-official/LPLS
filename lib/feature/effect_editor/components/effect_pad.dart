import 'package:fluent_ui/fluent_ui.dart' hide Colors;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' show Theme, Colors;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lpls/domain/di/di.dart';
import 'package:lpls/domain/enum/effect_instrument.dart';
import 'package:lpls/domain/enum/pad.dart';
import 'package:lpls/feature/effect_editor/effect_holder.dart';
import 'package:lpls/feature/effect_editor/effect_state.dart';
import 'package:lpls/feature/effect_editor/utils/palettes.dart';

final provider = StateNotifierProvider<EffectHolder, EffectState>(
  (ref) => di.effectHolder,
);

class EffectPad extends ConsumerWidget {
  final Pad pad;

  const EffectPad({super.key, required this.pad});

  @override
  Widget build(context, ref) {
    final state = ref.watch(provider);
    final manager = di.effectManager;
    final brightness = Theme.of(context).brightness;
    final padColor =
        manager.isFramesEmpty
            ? Colors.grey.shade400
            : resolveColor(state.effect?.frames[state.frameNumber][pad]);

    void paint(PointerEvent event) {
      if (event.buttons == 1) {
        if (state.instrument == EffectInstrument.brush) {
          manager.draw(pad, state.frameNumber, state.selectedColor);
        } else if (state.instrument == EffectInstrument.pipette) {
          manager.pickColor(pad, state.frameNumber);
        } else if (state.instrument == EffectInstrument.filling) {
          manager.floodfill(pad, state.frameNumber);
        }
      } else if (event.buttons == 2) {
        if (state.instrument == EffectInstrument.brush) {
          manager.draw(pad, state.frameNumber, manager.offColor);
        } else if (state.instrument == EffectInstrument.filling) {
          manager.floodfill(pad, state.frameNumber, isErase: true);
        }
      } else if ((event.buttons & kMiddleMouseButton) != 0) {
        manager.draw(pad, state.frameNumber, null);
      }
    }

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: MouseRegion(
        onEnter: (event) {
          if (manager.isDrawing) {
            paint(event);
          }
        },
        cursor: MouseCursor.defer,
        child: Listener(
          onPointerUp: (_) => manager.stopDrawing(),
          onPointerDown: (event) {
            if (state.instrument == EffectInstrument.brush) {
              manager.startDrawing();
            }            
            paint(event);
          },
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: padColor,
              border: Border.all(
                color:
                    brightness == Brightness.dark ? Colors.white : Colors.black,
              ),
            ),
            child:
                state.effect?.frames[state.frameNumber][pad] == null
                    ? const Placeholder()
                    : null,
          ),
        ),
      ),
    );
  }
}
