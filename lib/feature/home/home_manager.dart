import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:lpls/domain/di.dart';
import 'package:lpls/domain/entiy/manager_deps.dart';
import 'package:lpls/domain/enum/screen.dart';
import 'package:lpls/feature/home/home_holder.dart';
import 'package:lpls/feature/home/home_state.dart';

class HomeManager {
  final HomeHolder holder;
  final ManagerDeps deps;

  HomeManager({required this.deps, required this.holder});
  HomeState get state => holder.rState;
  List<MenuFlyoutItem> get fileMenuItems => _getFileMenuItems();

  void setScreen(Screen screen) => holder.setScreen(screen);

  void setTheme(ThemeMode theme) => holder.setTheme(theme);

  void toProjectScreen() => setScreen(Screen.project);
  void toTrackScreen() => setScreen(Screen.trackEditor);
  void toEffectScreen() => setScreen(Screen.effectEditor);

  Future<void> onOpen() async {
    if (state.screen == Screen.effectEditor) {
      await di.effectManager.openEffect();
    } else if (state.screen == Screen.project) {
      await di.projectManager.openProject();
    }
  }

  Future<void> onSave() async {
    if (state.screen == Screen.effectEditor) {
      await di.effectManager.saveEffect();
    } else if (state.screen == Screen.project) {
      await di.projectManager.saveProject();
    }
  }

  Future<void> onExport() async {
    await di.projectManager.exportProject();
  }

  List<MenuFlyoutItem> _getFileMenuItems() {
    final openItem = MenuFlyoutItem(text: const Text('Open...'), onPressed: onOpen);
    final saveItem = MenuFlyoutItem(text: const Text('Save'), onPressed: onSave);
    final exitItem = MenuFlyoutItem(text: const Text('Exit'), onPressed: () => exit(0));
    final exportItem = MenuFlyoutItem(text: const Text('Export'), onPressed: onExport);

    if (state.screen == Screen.project) {
      return [openItem, saveItem, exportItem, exitItem];
    }
    return [openItem, saveItem, exitItem];
  }
}