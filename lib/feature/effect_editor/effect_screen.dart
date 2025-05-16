import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show Icons, InputDecoration hide IconButton;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lpls/domain/di.dart';
import 'package:lpls/feature/effect_editor/components/effect_grid.dart';
import 'package:lpls/feature/effect_editor/components/palette_widget.dart';
import 'package:lpls/feature/effect_editor/effect_holder.dart';
import 'package:lpls/feature/effect_editor/effect_state.dart';

final provider = StateNotifierProvider<EffectHolder, EffectState>(
  (ref) => di.effectHolder,
);

const iconSize = 25.0;
const divider = Divider(
  size: iconSize,
  direction: Axis.vertical,
  style: DividerThemeData(
    thickness: 2.0,
    decoration: BoxDecoration(color: Colors.grey),
  ),
);

class EffectScreen extends ConsumerWidget {
  const EffectScreen({super.key});

  @override
  Widget build(context, ref) {
    final state = ref.watch(provider);
    final manager = di.effectManager;

    return ScaffoldPage(
      header: PageHeader(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: manager.goBack),
        title: Text(
          state.effect == null
              ? 'No effect'
              : 'Effect editor - frame #${state.frameNumber + 1}',
        ),
        commandBar: Wrap(
          children: [
            SizedBox(
              width: 100,
              child: NumberBox(
                clearButton: false,
                min: 0,
                value: manager.getBPMValue(),
                onChanged: manager.setBPM,
                format: manager.formatBPM,
                mode: SpinButtonPlacementMode.none,
              ),
            ),
            IconButton(
              icon: const Icon(FluentIcons.previous, size: iconSize),
              onPressed: manager.goToFirstFrame,
            ),
            IconButton(
              icon: const Icon(FluentIcons.stop, size: iconSize),
              onPressed: manager.stop,
            ),
            IconButton(
              icon: const Icon(FluentIcons.play_reverse_resume, size: iconSize),
              onPressed: state.isFirstFrame ? null : manager.goToPrevFrame,
            ),
            IconButton(
              icon: const Icon(FluentIcons.play, size: iconSize),
              onPressed: manager.play,
            ),
            IconButton(
              icon: const Icon(FluentIcons.pause, size: iconSize),
              onPressed: manager.pause,
            ),
            IconButton(
              icon: const Icon(FluentIcons.play_resume, size: iconSize),
              onPressed: state.isLastFrame ? null : manager.goToNextFrame,
            ),
            IconButton(
              icon: const Icon(FluentIcons.next, size: iconSize),
              onPressed: manager.goToLastFrame,
            ),
            divider,
            IconButton(
              icon: const Icon(FluentIcons.add, size: iconSize),
              onPressed: manager.addFrame,
            ),
            IconButton(
              icon: const Icon(FluentIcons.remove, size: iconSize),
              onPressed: state.isRemoveAvailable ? manager.removeFrame : null,
            ),
            divider,
            SplitButton(
              flyout: MenuFlyout(
                items: [
                  MenuFlyoutItem(
                    text: const Text('MK1 Palette'),
                    onPressed: () {},
                  ),
                  MenuFlyoutItem(
                    text: const Text('MK2 Palette'),
                    onPressed: () {},
                  ),
                ],
              ),
              child: Text('Palette'),
            ),
          ],
        ),
      ),
      content: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.maxHeight - 50;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (state.effect != null) const PaletteWidget(),
                      SizedBox(
                        width: size,
                        height: size,
                        child:
                            state.effect == null || state.effect!.frames.isEmpty
                                ? const Center(
                                  child: Text(
                                    'There is no effect yet.\nPlease edit effect from Project screen, or create one by clicking on the "+" icon.',
                                    textAlign: TextAlign.center,
                                  ),
                                )
                                : const EffectGrid(),
                      ),
                    ],
                  ),
                ),
                if (state.effect != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 4,
                    ),
                    child: manager.isFramesEmpty ? const Text('No frames for this effect') : Slider(
                      min: 0,
                      max: (state.effect!.frames.length - 1).toDouble(),
                      value: state.frameNumber.toDouble().clamp(
                        0,
                        (state.effect!.frames.length - 1).toDouble(),
                      ),
                      onChanged: (value) {
                        manager.goToFrame(value.round());
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
