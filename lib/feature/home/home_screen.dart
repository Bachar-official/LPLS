import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lpls/domain/di/di.dart';
import 'package:lpls/domain/entiy/app_locales.dart';
import 'package:lpls/domain/enum/screen.dart';
import 'package:lpls/feature/effect_editor/effect_screen.dart';
import 'package:lpls/feature/home/home_holder.dart';
import 'package:lpls/feature/home/home_state.dart';
import 'package:lpls/feature/project/project_screen.dart';
import 'package:lpls/feature/track_editor/track_editor_screen.dart';
import 'package:lpls/l10n/app_localizations.dart';

final provider = StateNotifierProvider<HomeHolder, HomeState>(
  (ref) => di.homeHolder,
);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(provider);
    final manager = di.homeManager;
    final locale = AppLocalizations.of(context);

    Widget getCurrentScreen() {
      switch (state.screen) {
        case Screen.project: return const ProjectScreen();
        case Screen.effectEditor: return const EffectScreen();
        case Screen.trackEditor: return const TrackEditorScreen();
      }
    }

    return NavigationView(
      appBar: NavigationAppBar(
        automaticallyImplyLeading: false,
        leading: MenuBar(
          items: [
            MenuBarItem(
              title: locale.file,
              items: manager.fileMenuItems,
            ),
            MenuBarItem(
              title: locale.screen,
              items: [
                RadioMenuFlyoutItem<Screen>(text: Text(locale.project), value: Screen.project, groupValue: state.screen, onChanged: manager.setScreen),
                RadioMenuFlyoutItem<Screen>(text: Text(locale.effect), value: Screen.effectEditor, groupValue: state.screen, onChanged: manager.setScreen),
              ],
            ),
            MenuBarItem(
              title: locale.theme,
              items: [
                RadioMenuFlyoutItem<ThemeMode>(text: Text(locale.theme_light), value: ThemeMode.light, groupValue: state.theme, onChanged: manager.setTheme),
                RadioMenuFlyoutItem<ThemeMode>(text: Text(locale.theme_dark), value: ThemeMode.dark, groupValue: state.theme, onChanged: manager.setTheme),
                RadioMenuFlyoutItem<ThemeMode>(text: Text(locale.theme_system), value: ThemeMode.system, groupValue: state.theme, onChanged: manager.setTheme),
              ],
            ),
            MenuBarItem(
              title: locale.locale,
              items: [
                RadioMenuFlyoutItem<AppLocales>(text: Text(locale.locale_en), value: AppLocales.en, groupValue: state.locale, onChanged: manager.setLocale),
                RadioMenuFlyoutItem<AppLocales>(text: Text(locale.locale_ru), value: AppLocales.ru, groupValue: state.locale, onChanged: manager.setLocale),
              ],
            ),
          ],
        ),
      ),
      content: getCurrentScreen(),
    );
  }
}
