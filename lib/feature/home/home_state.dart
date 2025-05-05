import 'package:lpls/domain/enum/screen.dart';

class HomeState {
  final Screen screen;

  const HomeState({required this.screen});

  HomeState.initial(): screen = Screen.project;

  HomeState copyWith({Screen? screen}) => HomeState(screen: screen ?? this.screen);
}