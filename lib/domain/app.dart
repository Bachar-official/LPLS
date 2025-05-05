import 'package:fluent_ui/fluent_ui.dart';
import 'package:lpls/feature/MIDI/midi_screen.dart';

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return FluentApp(home: MidiScreen());
  }
}
