import 'package:flutter/material.dart';
import 'package:lpls/domain/entiy/manager_deps.dart';
import 'package:lpls/domain/enum/screen.dart';
import 'package:lpls/feature/home/home_holder.dart';

class HomeManager {
  final HomeHolder holder;
  final ManagerDeps deps;

  HomeManager({required this.deps, required this.holder});

  void setScreen(Screen screen) => holder.setScreen(screen);

  void setTheme(ThemeMode theme) => holder.setTheme(theme);

  void toProjectScreen() => setScreen(Screen.project);
  void toTrackScreen() => setScreen(Screen.trackEditor);
  void toEffectScreen() => setScreen(Screen.effectEditor);
}