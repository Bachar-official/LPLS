import 'package:flutter/material.dart';
import 'package:lpls/constants/pad_structure.dart';
import 'package:lpls/domain/enum/mode.dart';
import 'package:lpls/feature/project/components/pads/pad_button.dart';
import 'package:lpls/utils/build_grid_pads.dart';

class PadGrid extends StatelessWidget {
  final PadStructure banks;
  final int page;
  final Mode mode;

  const PadGrid({
    super.key,
    required this.banks,
    required this.page,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        childAspectRatio: 1.0,
      ),
      itemCount: 64,
      itemBuilder: (context, index) {
        final pad = buildGridPads()[index];

        return PadButton(
          mode: mode,
          pad: pad,
          page: page,
        );
      },
    );
  }
}
