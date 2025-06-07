import 'package:flutter/material.dart';
import 'package:lpls/domain/entiy/app_locales.dart';
import 'package:lpls/domain/enum/screen.dart';

class HomeState {
  final Screen screen;
  final ThemeMode theme;
  final AppLocales locale;

  const HomeState({
    required this.screen,
    required this.theme,
    required this.locale,
  });

  HomeState.initial()
    : screen = Screen.project,
      theme = ThemeMode.system,
      locale = AppLocales.en;

  HomeState copyWith({Screen? screen, ThemeMode? theme, AppLocales? locale}) =>
      HomeState(
        screen: screen ?? this.screen,
        theme: theme ?? this.theme,
        locale: locale ?? this.locale,
      );
}
