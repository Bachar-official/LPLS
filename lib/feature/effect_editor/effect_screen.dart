import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show Icons;
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

class EffectScreen extends ConsumerWidget {
  const EffectScreen({super.key});

  @override
  Widget build(context, ref) {
    final state = ref.watch(provider);
    final manager = di.effectManager;

    return ScaffoldPage(
      header: PageHeader(
        title: Text(state.effect == null ? 'No effect' : 'Effect editor - frame #${state.frameNumber + 1}'),
        commandBar: CommandBar(
          primaryItems: [
            CommandBarButton(
              tooltip: 'First frame',
              icon: const Icon(FluentIcons.previous, size: iconSize),
              onPressed: manager.goToFirstFrame,
            ),
            CommandBarButton(
              tooltip: 'Stop',
              icon: const Icon(FluentIcons.stop, size: iconSize),
              onPressed: () {},
            ),
            CommandBarButton(
              tooltip: 'Previous frame',
              icon: const Icon(FluentIcons.play_reverse_resume, size: iconSize),
              onPressed: state.isFirstFrame ? null : manager.goToPrevFrame,
            ),
            CommandBarButton(
              tooltip: 'Play',
              icon: const Icon(FluentIcons.play, size: iconSize),
              onPressed: () {},
            ),
            CommandBarButton(
              tooltip: 'Pause',
              icon: const Icon(FluentIcons.pause, size: iconSize),
              onPressed: () {},
            ),
            CommandBarButton(
              tooltip: 'Next frame',
              icon: const Icon(FluentIcons.play_resume, size: iconSize),
              onPressed: state.isLastFrame ? null : manager.goToNextFrame,
            ),
            CommandBarButton(
              tooltip: 'Last frame',
              icon: const Icon(FluentIcons.next, size: iconSize),
              onPressed: manager.goToLastFrame,
            ),
            const CommandBarSeparator(),
            CommandBarButton(
              tooltip: 'Add frame',
              icon: const Icon(FluentIcons.add, size: iconSize),
              onPressed: manager.addFrame,
            ),
            CommandBarButton(
              tooltip: 'Remove frame',
              icon: const Icon(FluentIcons.remove, size: iconSize),
              onPressed: state.isRemoveAvailable ? manager.removeFrame : null,
            ),
            const CommandBarSeparator(),
            CommandBarButton(
              icon: SplitButton(
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
              onPressed: null,
            ),
          ],
        ),
      ),
      content: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.maxHeight - 16;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PaletteWidget(),
                SizedBox(
                  width: size,
                  height: size,
                  child:
                      state.effect == null
                          ? const Center(
                            child: Text(
                              'There is no effect yet.\nPlease edit effect from Project screen, or create one by clicking on the "+" icon.',
                              textAlign: TextAlign.center,
                            ),
                          )
                          : EffectGrid(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
