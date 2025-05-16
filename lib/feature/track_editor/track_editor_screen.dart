import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' hide Colors, IconButton;
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
        : ScaffoldPage(
          header: PageHeader(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: manager.goBack,
            ),
            title: Text('Track editor (${mode.name})'),
          ),
          content: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ReorderableListView(
                scrollDirection: Axis.horizontal,
                onReorder: (oldIndex, newIndex) {
                  // TODO: move this method to manager
                  state.bank?.reorderFiles(oldIndex, newIndex, isMidi: mode == Mode.midi);
                },
                children:
                    mode == Mode.audio
                        ? state.bank!.audioFiles
                            .map(
                              (file) => Expanded(
                                key: ValueKey(file.path),
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
                                key: ValueKey(file.path),
                                child: Container(
                                  color: Colors.green,
                                  child: Text(file.path),
                                ),
                              ),
                            )
                            .toList(),
              ),
            ),
          ),
        );
  }
}
