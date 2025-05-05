import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lpls/domain/di.dart';
import 'package:lpls/domain/enum/mode.dart';
import 'package:lpls/domain/entiy/pad_bank.dart';
import 'package:lpls/domain/enum/pad.dart';
import 'package:lpls/feature/project/project_holder.dart';
import 'package:lpls/feature/project/project_state.dart';

final provider = StateNotifierProvider<ProjectHolder, ProjectState>(
  (ref) => di.projectHolder,
);

class PadButton extends ConsumerWidget {
  final int page;
  final Pad pad;
  final Mode mode;

  const PadButton({
    super.key,
    required this.mode,
    required this.pad,
    required this.page,
  });

  Color _getPadColor(PadBank? bank) {
    if (bank == null) return Colors.black;
    if (mode == Mode.audio && bank.audioFiles.isNotEmpty) {
      return Colors.grey;
    } else if (mode == Mode.midi && bank.midiFiles.isNotEmpty) {
      return Colors.grey;
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(provider);
    final manager = di.projectManager;

    final bank = state.banks[page]?[pad]!;

    return Listener(
      onPointerDown: (event) {
        if (event.buttons == 2) {
          manager.sendCheckSignal(pad);
        }
        if (event.buttons == 1) {
          manager.foo();
        }
      },
      onPointerUp: (event) {
        manager.sendCheckSignal(pad, stop: true);
      },
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: _getPadColor(bank),
          border: Border.all(),
        ),
        child: DropTarget(
          onDragDone: (details) async {
            if (bank != null) {
              if (mode == Mode.audio) {
                manager.addFileToPad(page, pad, File(details.files.first.path), isMidi: mode == Mode.midi);
              }
            }
          },
          child: Text(
            mode == Mode.audio
                ? (bank?.audioFiles.length ?? 0).toString()
                : (bank?.midiFiles.length ?? 0).toString(),
          ),
        ),
      ),
    );
  }
}
