import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lpls/domain/di.dart';
import 'package:lpls/domain/enum/pad.dart';
import 'package:lpls/feature/effect_editor/effect_holder.dart';
import 'package:lpls/feature/effect_editor/effect_state.dart';

final provider = StateNotifierProvider<EffectHolder, EffectState>((ref) => di.effectHolder);

class EffectPad extends ConsumerWidget {
  final Pad pad;

  const EffectPad({super.key, required this.pad});

  @override
  Widget build(context, ref) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(),
        ),
      ),
    );
  }
}