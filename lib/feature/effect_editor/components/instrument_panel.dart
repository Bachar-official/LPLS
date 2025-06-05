import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lpls/domain/di/di.dart';
import 'package:lpls/domain/entiy/effect/direction.dart';
import 'package:lpls/domain/enum/enum.dart';
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
    final btness = Theme.of(context).brightness;

    final segmentedButtonStyle = SegmentedButton.styleFrom(
              side: BorderSide(
                color: btness == Brightness.dark ? Colors.white : Colors.black,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            );

    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (state.selectedColor != null) SegmentedButton<Btness>(
            emptySelectionAllowed: false,
            multiSelectionEnabled: false,
            direction: Axis.vertical,
            segments:
                Btness.values
                    .map(
                      (btness) => ButtonSegment<Btness>(
                        value: btness,
                        icon: getBtnessIcon(state.selectedColor?.$1, btness),
                      ),
                    )
                    .toList(),
            selected: {manager.selectedBrightness ?? Btness.light},
            onSelectionChanged: manager.selectBrightness,
            showSelectedIcon: false,
            style: segmentedButtonStyle,
          ),
          SegmentedButton<EffectInstrument>(
            emptySelectionAllowed: false,
            multiSelectionEnabled: false,
            direction: Axis.vertical,
            segments:
                EffectInstrument.values
                    .map(
                      (inst) => ButtonSegment<EffectInstrument>(
                        value: inst,
                        icon: inst.toImage(),
                        tooltip: inst.displayName,
                      ),
                    )
                    .toList(),
            showSelectedIcon: false,
            selected: {state.instrument},
            onSelectionChanged: manager.setInstrument,
            style: segmentedButtonStyle,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                color: btness == Brightness.dark ? Colors.white : Colors.black,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...Direction.values.map(
                  (dir) => IconButton(
                    style: IconButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    icon: dir.icon,
                    tooltip: dir.tooltip,
                    onPressed: () => manager.shiftFrame(dir),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
