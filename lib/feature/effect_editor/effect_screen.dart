import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lpls/domain/di.dart';
import 'package:lpls/feature/effect_editor/components/effect_grid.dart';
import 'package:lpls/feature/effect_editor/effect_holder.dart';
import 'package:lpls/feature/effect_editor/effect_state.dart';

final provider = StateNotifierProvider<EffectHolder, EffectState>(
  (ref) => di.effectHolder,
);

class EffectScreen extends ConsumerWidget {
  const EffectScreen({super.key});

  @override
  Widget build(context, ref) {
    final state = ref.watch(provider);
    final manager = di.effectManager;

    return ScaffoldPage(
      header: PageHeader(
        title: Text('Effect editor - frame #${state.frameNumber + 1}'),
        commandBar: CommandBar(
          primaryItems: [
            CommandBarButton(
              tooltip: 'First frame',
              icon: const Icon(FluentIcons.previous),
              onPressed: manager.goToFirstFrame,
            ),
            CommandBarButton(
              tooltip: 'Stop',
              icon: const Icon(FluentIcons.stop),
              onPressed: () {},
            ),
            CommandBarButton(
              tooltip: 'Previous frame',
              icon: const Icon(FluentIcons.play_reverse_resume),
              onPressed: state.isFirstFrame ? null : manager.goToPrevFrame,
            ),
            CommandBarButton(
              tooltip: 'Play',
              icon: const Icon(FluentIcons.play),
              onPressed: () {},
            ),
            CommandBarButton(
              tooltip: 'Pause',
              icon: const Icon(FluentIcons.pause),
              onPressed: () {},
            ),
            CommandBarButton(
              tooltip: 'Next frame',
              icon: const Icon(FluentIcons.play_resume),
              onPressed: state.isLastFrame ? null : manager.goToNextFrame,
            ),
            CommandBarButton(
              tooltip: 'Last frame',
              icon: const Icon(FluentIcons.next),
              onPressed: manager.goToLastFrame,
            ),
            const CommandBarSeparator(),
            CommandBarButton(
              tooltip: 'Add frame',
              icon: const Icon(FluentIcons.add),
              onPressed: manager.addFrame,
            ),
            CommandBarButton(
              tooltip: 'Remove frame',
              icon: const Icon(FluentIcons.remove),
              onPressed: state.isSingleFrame ? null : manager.removeFrame,
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
                const Text('Palette'),
                SizedBox(
                  width: size,
                  height: size,
                  child: EffectGrid(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
