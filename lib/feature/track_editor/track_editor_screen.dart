import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' hide Colors, IconButton;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lpls/domain/di/di.dart';
import 'package:lpls/domain/enum/mode.dart';
import 'package:lpls/feature/project/project_holder.dart';
import 'package:lpls/feature/project/project_state.dart';
import 'package:lpls/feature/track_editor/components/sample_widget.dart';
import 'package:lpls/feature/track_editor/track_holder.dart';
import 'package:lpls/feature/track_editor/track_state.dart';
import 'package:lpls/l10n/app_localizations.dart';

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
    final locale = AppLocalizations.of(context);

    return state.bank == null
        ? Center(child: Text(locale.no_files))
        : state.isLoading
        ? const Center(child: CircularProgressIndicator())
        : ScaffoldPage(
          header: PageHeader(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: manager.goBack,
            ),
            title: Text(locale.track_editor(mode.name)),
          ),
          content: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ReorderableListView(
                scrollDirection: Axis.horizontal,
                onReorder: (oldIndex, newIndex) {
                  manager.reorderTracks(oldIndex, newIndex);
                },
                children:
                    mode == Mode.audio
                        ? state.bank!.audioFiles
                            .asMap()
                            .map(
                              (index, file) => MapEntry(
                                index,
                                SampleWidget(
                                  key: ValueKey(file.path),
                                  index: index,
                                  file: file,
                                  onRemove: manager.removeFile,
                                ),
                              ),
                            )
                            .values
                            .toList()
                        : state.bank!.midiFiles
                            .asMap()
                            .map(
                              (index, file) => MapEntry(
                                index,
                                GestureDetector(
                                  key: ValueKey(file.path),
                                  onTap: () => manager.onClickTrack(index, true),
                                  child: SampleWidget(                                    
                                    index: index,
                                    file: file,
                                    isMidi: true,
                                    onRemove: manager.removeFile,
                                  ),
                                ),
                              ),
                            )
                            .values
                            .toList(),
              ),
            ),
          ),
        );
  }
}
