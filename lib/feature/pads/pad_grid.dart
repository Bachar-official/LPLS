import 'package:flutter/material.dart';
import 'package:lpls/constants/pad_structure.dart';
import 'package:lpls/domain/enum/mode.dart';
import 'package:lpls/domain/enum/pad.dart';
import 'package:lpls/feature/pads/pad_button.dart';

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
        final pad = _buildGridPads()[index];

        return PadButton(
          mode: mode,
          pad: pad,
          page: page,
        );
      },
    );
  }

  List<Pad> _buildGridPads() {
    const rows = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
    const cols = ['1', '2', '3', '4', '5', '6', '7', '8'];

    return [
      for (final row in rows)
        for (final col in cols)
          Pad.values.firstWhere((p) => p.name == '$row$col')
    ];
  }
}
