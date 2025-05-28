import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lpls/domain/di/mobile_di.dart';
import 'package:lpls/feature/mobile_project/mobile_project_holder.dart';
import 'package:lpls/feature/mobile_project/mobile_project_screen.dart';
import 'package:lpls/feature/mobile_project/mobile_project_state.dart';

final provider = StateNotifierProvider<MobileProjectHolder, MobileProjectState>((ref) => mobileDI.projectHolder);

class MobileApp extends ConsumerWidget {
  const MobileApp({super.key});

  @override
  Widget build(context, ref) {
    final state = ref.watch(provider);

    return MaterialApp(
      home: MobileProjectScreen(),
      scaffoldMessengerKey: mobileDI.scaffoldKey,
    );
  }
}