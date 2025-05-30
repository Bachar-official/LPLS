import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lpls/domain/di/di.dart';
import 'package:lpls/domain/enum/effect_instrument.dart';
import 'package:lpls/feature/effect_editor/effect_holder.dart';
import 'package:lpls/feature/effect_editor/effect_state.dart';
import 'package:lpls/feature/effect_editor/utils/palettes.dart';

final provider = StateNotifierProvider<EffectHolder, EffectState>(
  (ref) => di.effectHolder,
);

class InstrumentPanel extends ConsumerWidget {
  const InstrumentPanel({super.key});

  @override
  Widget build(context, ref) {
    final state = ref.watch(provider);
    final manager = di.effectManager;

    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Tooltip(
            message: 'Selected color',
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(color: resolveColor(state.selectedColor), borderRadius: BorderRadius.circular(25)),
            ),
          ),
          SegmentedButton<EffectInstrument>(
            emptySelectionAllowed: false,
            multiSelectionEnabled: false,
            direction: Axis.vertical,
            segments: EffectInstrument.values.map(
              (inst) => ButtonSegment<EffectInstrument>(
                value: inst,
                icon: inst.toImage(),
              ),
            ).toList(),
            showSelectedIcon: false,
            selected: {state.instrument},
            onSelectionChanged: manager.setInstrument,
          ),
        ],
      ),
    );
  }
}
