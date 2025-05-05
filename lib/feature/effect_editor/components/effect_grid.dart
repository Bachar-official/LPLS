import 'package:flutter/material.dart';
import 'package:lpls/feature/effect_editor/components/effect_pad.dart';
import 'package:lpls/utils/build_grid_pads.dart';

class EffectGrid extends StatelessWidget {
  const EffectGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        childAspectRatio: 1.0,
      ),
      itemCount: 64,
      itemBuilder: (ctx, index) {
        final pad = buildGridPads()[index];

        return EffectPad(
          pad: pad,
        );
      },);
  }
}