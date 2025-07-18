import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lpls/domain/di/di.dart';
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
      return Colors.black12;
    } else if (mode == Mode.midi && bank.midiFiles.isNotEmpty) {
      return Colors.black12;
    }
    return Colors.grey.shade400;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(provider);
    final manager = di.projectManager;

    final bank = state.banks[page]?[pad]!;
    final brightness = Theme.of(context).brightness;

    return MouseRegion(
      onEnter: (_) => manager.hoverPad(pad),
      onExit: (_) => manager.leavePad(),
      child: KeyboardListener(
        focusNode: FocusNode()..requestFocus(),
        autofocus: true,
        onKeyEvent: (event) {
          if (event is KeyDownEvent) {
            if(event.logicalKey == LogicalKeyboardKey.delete) {
              manager.clearBank();
            }
          }          
        },
        child: Listener(
          onPointerDown: (event) {
            if (event.buttons == 2) {
              manager.sendCheckSignal(pad);
            }
            if (event.buttons == 1) {
              manager.selectPad(pad);
            }
          },
          onPointerUp: (event) {
            manager.sendCheckSignal(pad, stop: true);
          },
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: _getPadColor(bank),
                border: Border.all(color: brightness == Brightness.dark ? Colors.white : Colors.black),
              ),
              child: DropTarget(
                onDragDone: (details) async {
                  if (bank != null) {
                      manager.addFileToPad(page, pad, File(details.files.first.path), isMidi: mode == Mode.midi);
                  }
                },
                child: Text(
                  mode == Mode.audio
                      ? (bank?.audioFiles.length ?? 0).toString()
                      : (bank?.midiFiles.length ?? 0).toString(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
