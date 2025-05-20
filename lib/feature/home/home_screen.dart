import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lpls/domain/di.dart';
import 'package:lpls/domain/enum/screen.dart';
import 'package:lpls/feature/effect_editor/effect_screen.dart';
import 'package:lpls/feature/home/home_holder.dart';
import 'package:lpls/feature/home/home_state.dart';
import 'package:lpls/feature/project/project_screen.dart';
import 'package:lpls/feature/track_editor/track_editor_screen.dart';
import 'package:window_manager/window_manager.dart';

final provider = StateNotifierProvider<HomeHolder, HomeState>(
  (ref) => di.homeHolder,
);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(provider);
    final manager = di.homeManager;

    Widget _getCurrentScreen() {
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
              title: 'File',
              items: [
                MenuFlyoutItem(text: const Text('Open...'), onPressed: manager.onOpen),
                MenuFlyoutItem(text: const Text('Save'), onPressed: manager.onSave),
                MenuFlyoutItem(text: const Text('Exit'), onPressed: () => exit(0)),
              ],
            ),
            MenuBarItem(
              title: 'Screen',
              items: [
                RadioMenuFlyoutItem<Screen>(text: const Text('Project'), value: Screen.project, groupValue: state.screen, onChanged: manager.setScreen),
                RadioMenuFlyoutItem<Screen>(text: const Text('Track editor'), value: Screen.trackEditor, groupValue: state.screen, onChanged: manager.setScreen),
                RadioMenuFlyoutItem<Screen>(text: const Text('Effect editor'), value: Screen.effectEditor, groupValue: state.screen, onChanged: manager.setScreen),
              ],
            ),
            MenuBarItem(
              title: 'Theme',
              items: [
                RadioMenuFlyoutItem<ThemeMode>(text: const Text('Light'), value: ThemeMode.light, groupValue: state.theme, onChanged: manager.setTheme),
                RadioMenuFlyoutItem<ThemeMode>(text: const Text('Dark'), value: ThemeMode.dark, groupValue: state.theme, onChanged: manager.setTheme),
                RadioMenuFlyoutItem<ThemeMode>(text: const Text('System'), value: ThemeMode.system, groupValue: state.theme, onChanged: manager.setTheme),
              ],
            ),
          ],
        ),
        title: DragToMoveArea(
          child: SizedBox(
            height: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'LPLS',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        actions: WindowButtons(),
      ),
      content: _getCurrentScreen(),
    );
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final FluentThemeData theme = FluentTheme.of(context);

    return SizedBox(
      width: 138,
      height: 50,
      child: WindowCaption(
        brightness: theme.brightness,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
