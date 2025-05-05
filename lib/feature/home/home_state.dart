import 'package:flutter/material.dart';
import 'package:lpls/domain/enum/screen.dart';

class HomeState {
  final Screen screen;
  final ThemeMode theme;

  const HomeState({required this.screen, required this.theme});

  HomeState.initial(): screen = Screen.project, theme = ThemeMode.system;

  HomeState copyWith({Screen? screen, ThemeMode? theme}) => HomeState(screen: screen ?? this.screen, theme: theme ?? this.theme);
}