import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lpls/domain/entiy/mode.dart';
import 'package:lpls/domain/entiy/pad_bank.dart';

class PadButton extends StatelessWidget {
  final PadBank bank;
  final Mode mode;
  final VoidCallback onRightClickDown;
  final VoidCallback onRightClickUp;
  const PadButton({
    super.key,
    required this.bank,
    required this.mode,
    required this.onRightClickDown,
    required this.onRightClickUp,
  });

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
    return Listener(
      onPointerDown: (event) {
        if (event.buttons == 2) {
          onRightClickDown();
        }
      },
      onPointerUp: (event) {
        onRightClickUp();
      },
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: _getPadColor(), border: Border.all()),
      ),
    );
  }
}
