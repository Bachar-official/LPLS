import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lpls/domain/di/di.dart';
import 'package:lpls/feature/home/home_holder.dart';
import 'package:lpls/feature/home/home_screen.dart';
import 'package:lpls/feature/home/home_state.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lpls/l10n/app_localizations.dart';

final provider = StateNotifierProvider<HomeHolder, HomeState>(
  (ref) => di.homeHolder,
);

class App extends ConsumerWidget {
  const App({super.key});
  @override
  Widget build(context, ref) {
    final state = ref.watch(provider);
    return FluentApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en'),
        Locale('ru'),
      ],
      locale: Locale(state.locale.name),
      home: HomeScreen(),
      themeMode: state.theme,
      darkTheme: FluentThemeData.dark(),
      navigatorKey: di.navigatorKey,
      builder: (context, child) => Overlay(
        initialEntries: [
          OverlayEntry(builder: (ctx) => child!),
        ],
      ),
    );
  }
}
