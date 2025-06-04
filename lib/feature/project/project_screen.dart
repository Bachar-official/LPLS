import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' hide MenuBar, Colors, IconButton, Slider;
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:lpls/domain/di/di.dart';
import 'package:lpls/domain/enum/mode.dart';
import 'package:lpls/feature/project/project_holder.dart';
import 'package:lpls/feature/project/project_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lpls/feature/project/components/pads/pad_grid.dart';
import 'package:lpls/utils/fill_initial_banks.dart';

final provider = StateNotifierProvider<ProjectHolder, ProjectState>(
  (ref) => di.projectHolder,
);

class ProjectScreen extends ConsumerWidget {
  const ProjectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(provider);
    final manager = di.projectManager;

    return state.isLoading
        ? Center(child: const ProgressRing())
        : ScaffoldPage(
          header: PageHeader(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.device == null
                      ? 'No device'
                      : 'Current page: ${state.page + 1}',
                ),
                const SizedBox(width: 20),
                Slider(value: state.volume, onChanged: isPadStructureEmpty(state.banks) ? null : manager.setVolume, min: 0.0, max: 1.0),
              ],
            ),
            commandBar: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ComboBox<MidiDevice?>(
                  onChanged: manager.setDevice,
                  placeholder: const Text('Select MIDI device'),
                  disabledPlaceholder: const Text('Devices not found'),
                  value: state.device,
                  items:
                      state.devices
                          .map(
                            (e) => ComboBoxItem<MidiDevice>(
                              value: e,
                              child: Text(e.name),
                            ),
                          )
                          .toList(),
                ),
                IconButton(
                  icon: const Icon(Icons.cloud_off, size: 24),
                  onPressed: manager.isConnected ? manager.disconnect : null,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 24),
                  onPressed: manager.getDevices,
                ),
                SegmentedButton<Mode>(
                  segments: [
                    ButtonSegment(
                      label: const Text('Audio'),
                      value: Mode.audio,
                    ),
                    ButtonSegment(label: const Text('MIDI'), value: Mode.midi),
                  ],
                  selected: {state.mode},
                  onSelectionChanged:
                      manager.isConnected ? manager.setMode : null,
                ),
              ],
            ),
          ),
          content: LayoutBuilder(
            builder: (context, constraints) {
              final size = constraints.maxHeight - 16;
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: SizedBox(
                    width: size,
                    height: size,
                    child:
                        state.device == null
                            ? const Center(
                              child: Text(
                                'No devices connected or incompatible device connected',
                              ),
                            )
                            : PadGrid(
                              page: state.page,
                              mode: state.mode,
                              banks: state.banks,
                            ),
                  ),
                ),
              );
            },
          ),
        );
  }
}
