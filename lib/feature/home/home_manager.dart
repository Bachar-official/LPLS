import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:lpls/domain/di/di.dart';
import 'package:lpls/domain/entiy/app_locales.dart';
import 'package:lpls/domain/entiy/manager_deps.dart';
import 'package:lpls/domain/enum/screen.dart';
import 'package:lpls/feature/home/home_holder.dart';
import 'package:lpls/feature/home/home_state.dart';
import 'package:lpls/l10n/app_localizations.dart';

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
  void toEffectScreen() {
    di.effectManager.setFromTrackEditor(state.screen == Screen.trackEditor);
    setScreen(Screen.effectEditor);
  }

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

  Future<void> onSaveAs() async {
    if (state.screen == Screen.project) {
      await di.projectManager.saveProject(saveAs: true);
    } else if (state.screen == Screen.effectEditor) {
      await di.effectManager.saveEffect(saveAs: true);
    }
  }

  Future<void> onExport() async {
    await di.projectManager.exportProject();
  }

  Future<void> onImport() async {
    await di.projectManager.importProject();
  }

  void onClearEffect() => di.effectManager.clearEffect();

  void setLocale(AppLocales locale) => holder.setLocale(locale);

  List<MenuFlyoutItem> _getFileMenuItems() {
    final ctx = deps.navigatorKey.currentContext!;
    final locale = AppLocalizations.of(ctx);

    final openItem = MenuFlyoutItem(
      text: Text(locale.open),
      onPressed: onOpen,
    );
    final saveItem = MenuFlyoutItem(
      text: Text(locale.save),
      onPressed: onSave,
    );
    final saveAsItem = MenuFlyoutItem(
      text: Text(locale.save_as),
      onPressed: onSaveAs,
    );
    final exitItem = MenuFlyoutItem(
      text: Text(locale.exit),
      onPressed: () => exit(0),
    );
    final exportItem = MenuFlyoutItem(
      text: Text(locale.export),
      onPressed: onExport,
    );
    final importItem = MenuFlyoutItem(
      text: Text(locale.import),
      onPressed: onImport,
    );
    final clearEffectItem = MenuFlyoutItem(
      text: Text(locale.effect_clear),
      onPressed: onClearEffect,
    );

    if (state.screen == Screen.project) {
      return [openItem, saveItem, saveAsItem, exportItem, importItem, exitItem];
    }
    return [openItem, saveItem, saveAsItem, clearEffectItem, exitItem];
  }
}
