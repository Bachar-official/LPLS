import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lpls/domain/di.dart';
import 'package:lpls/feature/home/home_holder.dart';
import 'package:lpls/feature/home/home_screen.dart';
import 'package:lpls/feature/home/home_state.dart';

final provider = StateNotifierProvider<HomeHolder, HomeState>(
  (ref) => di.homeHolder,
);

class App extends ConsumerWidget {
  const App({super.key});
  @override
  Widget build(context, ref) {
    final state = ref.watch(provider);
    return FluentApp(home: HomeScreen(), themeMode: state.theme, darkTheme: FluentThemeData.dark(),);
  }
}
