import 'package:flutter/material.dart';
import 'package:flutter_application_1/domain/di.dart';
import 'package:flutter_application_1/feature/MIDI/midi_holder.dart';
import 'package:flutter_application_1/feature/MIDI/midi_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      ),
      body: Column(
        children: [
          DropdownButton(
            value: state.device,
            items:
                state.devices
                    .map((d) => DropdownMenuItem(value: d, child: Text(d.name)))
                    .toList(),
            onChanged: manager.setDevice,
          ),
          ElevatedButton(
            onPressed: manager.disconnect,
            child: const Text('Disconnect'),
          ),
          ElevatedButton(
            onPressed: manager.getDevices,
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}
