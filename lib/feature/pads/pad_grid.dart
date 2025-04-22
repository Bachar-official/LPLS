import 'package:flutter/material.dart';
import 'package:lpls/constants/pad_structure.dart';
import 'package:lpls/domain/entiy/mode.dart';
import 'package:lpls/domain/entiy/pad_bank.dart';
import 'package:lpls/feature/pads/pad_button.dart';

class PadGrid extends StatelessWidget {
  final PadStructure banks;
  final int page;
  final Mode mode;

  const PadGrid({super.key, required this.banks, required this.page, required this.mode});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        childAspectRatio: 1.0,
      ),
      itemCount: 64,
      itemBuilder: (context, index) {
        int buttonNumber = _getButtonNumber(index);

        final bank = banks[page]?[buttonNumber];

        return PadButton(bank: bank ?? PadBank.initial(), mode: mode);
      },
    );
  }

  int _getButtonNumber(int index) {
    int row = index ~/ 8 + 1;
    int col = index % 8 + 1;
    return row * 10 + col;
  }
}
