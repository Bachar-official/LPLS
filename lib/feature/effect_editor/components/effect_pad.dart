import 'package:fluent_ui/fluent_ui.dart' hide Colors;
import 'package:flutter/material.dart' show Theme, Colors;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lpls/domain/di.dart';
import 'package:lpls/domain/enum/pad.dart';
import 'package:lpls/feature/effect_editor/effect_holder.dart';
import 'package:lpls/feature/effect_editor/effect_state.dart';
import 'package:lpls/feature/effect_editor/utils/palettes.dart';

final provider = StateNotifierProvider<EffectHolder, EffectState>((ref) => di.effectHolder);

class EffectPad extends ConsumerWidget {
  final Pad pad;

  const EffectPad({super.key, required this.pad});

  @override
  Widget build(context, ref) {
    final state = ref.watch(provider);
    final manager = di.effectManager;
    final brightness = Theme.of(context).brightness;
    final padColor = manager.isFramesEmpty ? Colors.grey.shade400 : resolveColor(state.effect?.frames[state.frameNumber][pad]);

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Listener(
        onPointerDown: (event) {
          if (event.buttons == 1) {
            manager.draw(pad, state.frameNumber, state.selectedColor);
          } else if (event.buttons == 2) {
            manager.draw(pad, state.frameNumber, null);
          }          
        },
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: padColor,
            border: Border.all(color: brightness == Brightness.dark ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }
}