import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lpls/domain/di/mobile_di.dart';
import 'package:lpls/feature/mobile_project/mobile_project_holder.dart';
import 'package:lpls/feature/mobile_project/mobile_project_state.dart';

final provider = StateNotifierProvider<MobileProjectHolder, MobileProjectState>(
  (ref) => mobileDI.projectHolder,
);

class MobileProjectScreen extends ConsumerWidget {
  const MobileProjectScreen({super.key});

  @override
  Widget build(context, ref) {
    final state = ref.watch(provider);
    final manager = mobileDI.projectManager;

    return Scaffold(
          appBar: AppBar(
            title: Text(
              state.device == null
                  ? 'No device'
                  : 'Current page: ${state.page + 1}',
            ),
            actions: [
              DropdownButton<MidiDevice?>(
                items:
                    state.devices
                        .map(
                          (e) => DropdownMenuItem<MidiDevice>(
                            value: e,
                            child: Text(e.name),
                          ),
                        )
                        .toList(),
                onChanged: manager.setDevice,
                value: state.device,
                disabledHint: const Text('Devices not found'),
                hint: const Text('Select device'),
              ),
              IconButton(
                icon: const Icon(Icons.cloud_off, size: 24),
                onPressed: manager.isConnected ? manager.disconnect : null,
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 24),
                onPressed: manager.getDevices,
              ),
            ],
          ),
          body:
              state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        state.isProjectEmpty
                            ? const Text(
                              'Project is empty.\nPlease import or open existing one.',
                              textAlign: TextAlign.center,
                            )
                            : const Text('Project opened!'),
                        if (state.isProjectEmpty)
                          ElevatedButton(
                            onPressed: manager.importProject,
                            child: const Text('Import project'),
                          ),
                      ],
                    ),
                  ),
        );
  }
}
