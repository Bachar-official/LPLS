import 'package:flutter/material.dart';
import 'package:lpls/domain/entiy/mode.dart';
import 'package:lpls/domain/entiy/pad_bank.dart';

class PadButton extends StatelessWidget {
  final PadBank bank;
  final Mode mode;
  const PadButton({super.key, required this.bank, required this.mode});

  Color _getPadColor() {
    if (mode == Mode.audio && bank.audioFiles.isNotEmpty) {
      return Colors.grey;
    } else if (mode == Mode.midi && bank.midiFiles.isNotEmpty) {
      return Colors.grey;
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: _getPadColor(),
        border: Border.all()
      ),
    );
  }
}