import 'package:flutter/material.dart';
import 'package:lpls/domain/di.dart';
import 'package:lpls/domain/entiy/mode.dart';
import 'package:lpls/feature/MIDI/midi_holder.dart';
import 'package:lpls/feature/MIDI/midi_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lpls/feature/pads/pad_grid.dart';

final provider = StateNotifierProvider<MidiHolder, MidiState>(
  (ref) => di.midiHolder,
);

class MidiScreen extends ConsumerWidget {
  const MidiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(provider);
    final manager = di.midiManager;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          state.device == null
              ? 'No device'
              : 'Current mode : ${state.mode.name}, current page: ${state.page + 1}',
        ),
        actions: [
          DropdownButton(
            disabledHint: const Text('MIDI Devices not found'),
            value: state.device,
            items:
                state.devices
                    .map((d) => DropdownMenuItem(value: d, child: Text(d.name)))
                    .toList(),
            onChanged: manager.setDevice,
          ),
          SegmentedButton<Mode>(
            segments: [
              ButtonSegment(label: const Text('Audio'), value: Mode.audio),
              ButtonSegment(label: const Text('MIDI'), value: Mode.midi),
            ],
            selected: {state.mode},
            onSelectionChanged: manager.isConnected ? manager.setMode : null,
          ),
          IconButton(
            icon: const Icon(Icons.cloud_off),
            onPressed: manager.isConnected ? manager.disconnect : null,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: manager.getDevices,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.maxHeight - 16;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: SizedBox(
                width: size,
                height: size,
                child: PadGrid(
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
