import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' hide MenuBar, Colors, IconButton;
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:lpls/domain/di.dart';
import 'package:lpls/domain/enum/mode.dart';
import 'package:lpls/feature/MIDI/midi_holder.dart';
import 'package:lpls/feature/MIDI/midi_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lpls/feature/pads/pad_grid.dart';
import 'package:window_manager/window_manager.dart';

final provider = StateNotifierProvider<MidiHolder, MidiState>(
  (ref) => di.midiHolder,
);

class MidiScreen extends ConsumerWidget {
  const MidiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(provider);
    final manager = di.midiManager;

    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text(
    //       state.device == null
    //           ? 'No device'
    //           : 'Current mode : ${state.mode.name}, current page: ${state.page + 1}',
    //     ),
    //     actions: [
    //       SizedBox(
    //         width: 40,
    //         height: 40,
    //         child: TextField(controller: manager.vText),
    //       ),
    //       DropdownButton(
    //         disabledHint: const Text('MIDI Devices not found'),
    //         value: state.device,
    //         items:
    //             state.devices
    //                 .map((d) => DropdownMenuItem(value: d, child: Text(d.name)))
    //                 .toList(),
    //         onChanged: manager.setDevice,
    //       ),
    //       SegmentedButton<Mode>(
    //         segments: [
    //           ButtonSegment(label: const Text('Audio'), value: Mode.audio),
    //           ButtonSegment(label: const Text('MIDI'), value: Mode.midi),
    //         ],
    //         selected: {state.mode},
    //         onSelectionChanged: manager.isConnected ? manager.setMode : null,
    //       ),
    //       IconButton(
    //         icon: const Icon(Icons.cloud_off),
    //         onPressed: manager.isConnected ? manager.disconnect : null,
    //       ),
    //       IconButton(
    //         icon: const Icon(Icons.refresh),
    //         onPressed: manager.getDevices,
    //       ),
    //     ],
    //   ),
    //   body:
    //       state.isLoading
    //           ? const Center(child: CircularProgressIndicator())
    //           : LayoutBuilder(
    //             builder: (context, constraints) {
    //               final size = constraints.maxHeight - 16;
    //               return Padding(
    //                 padding: const EdgeInsets.all(8.0),
    //                 child: Center(
    //                   child: SizedBox(
    //                     width: size,
    //                     height: size,
    //                     child: PadGrid(
    //                       page: state.page,
    //                       mode: state.mode,
    //                       banks: state.banks,
    //                     ),
    //                   ),
    //                 ),
    //               );
    //             },
    //           ),
    // );
    return NavigationView(
      appBar: NavigationAppBar(
        automaticallyImplyLeading: false,
        leading: MenuBar(
          items: [
            MenuBarItem(
              title: 'File',
              items: [
                MenuFlyoutItem(text: const Text('Exit'), onPressed: () => {}),
              ],
            ),
          ],
        ),
        title: DragToMoveArea(
          child: SizedBox(
            height: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'LPLS',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        actions: WindowButtons(),
      ),
      content:
          state.isLoading
              ? const ProgressRing()
              : ScaffoldPage(
                header: PageHeader(
                  title: Text(
                    state.device == null
                        ? 'No device'
                        : 'Current mode : ${state.mode.name}, current page: ${state.page + 1}',
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
                        onPressed:
                            manager.isConnected ? manager.disconnect : null,
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
                          ButtonSegment(
                            label: const Text('MIDI'),
                            value: Mode.midi,
                          ),
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
              ),
    );
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final FluentThemeData theme = FluentTheme.of(context);

    return SizedBox(
      width: 138,
      height: 50,
      child: WindowCaption(
        brightness: theme.brightness,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
