import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lpls/domain/di.dart';
import 'package:lpls/domain/enum/mode.dart';
import 'package:lpls/feature/project/project_holder.dart';
import 'package:lpls/feature/project/project_state.dart';
import 'package:lpls/feature/track_editor/track_holder.dart';
import 'package:lpls/feature/track_editor/track_state.dart';

final provider = StateNotifierProvider<TrackHolder, TrackState>(
  (ref) => di.trackHolder,
);
final projectProvider = StateNotifierProvider<ProjectHolder, ProjectState>(
  (ref) => di.projectHolder,
);

class TrackEditorScreen extends ConsumerWidget {
  const TrackEditorScreen({super.key});

  @override
  Widget build(context, ref) {
    final state = ref.watch(provider);
    final mode = ref.watch(projectProvider).mode;
    final manager = di.trackManager;

    return state.bank == null
        ? const Center(child: Text('No filed attached yet'))
        : Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children:
                mode == Mode.audio
                    ? state.bank!.audioFiles
                        .map(
                          (file) => Expanded(
                            child: Container(
                              color: Colors.red,
                              child: Text(file.path),
                            ),
                          ),
                        )
                        .toList()
                    : state.bank!.midiFiles
                        .map(
                          (file) => Expanded(
                            child: Container(
                              color: Colors.green,
                              child: Text(file.path),
                            ),
                          ),
                        )
                        .toList(),
          ),
        );
  }
}
