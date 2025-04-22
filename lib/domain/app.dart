import 'package:flutter/material.dart';
import 'package:lpls/feature/MIDI/midi_screen.dart';

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MidiScreen());
  }
}
