import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lpls/domain/enum/screen.dart';
import 'package:lpls/feature/home/home_state.dart';

class HomeHolder extends StateNotifier<HomeState> {
  HomeHolder() : super(HomeState.initial());

  HomeState get rState => state;

  void setScreen(Screen screen) {
    state = state.copyWith(screen: screen);
  }

  void setTheme(ThemeMode theme) {
    state = state.copyWith(theme: theme);
  }
}