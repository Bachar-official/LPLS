import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lpls/domain/di/di.dart';
import 'package:lpls/feature/effect_editor/effect_holder.dart';
import 'package:lpls/feature/effect_editor/effect_state.dart';
import 'package:lpls/feature/effect_editor/utils/palettes.dart';

final provider = StateNotifierProvider<EffectHolder, EffectState>(
  (ref) => di.effectHolder,
);

class PaletteWidget extends ConsumerWidget {
  const PaletteWidget({super.key});

  @override
  Widget build(context, ref) {
    // final state = ref.watch(provider);
    final manager = di.effectManager;

    return CommandBar(
      direction: Axis.vertical,
      isCompact: true,
      overflowBehavior: CommandBarOverflowBehavior.wrap,
      primaryItems:
          manager.generatedPalette
              .map(
                (e) => CommandBarButton(
                  icon: SizedBox(width: 20, height: 20, child: ColoredBox(color: resolveColor(e))),
                  onPressed: () => manager.selectColor(e),
                ),
              )
              .toList(),
    );
  }
}
