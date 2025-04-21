import 'package:flutter_application_1/feature/MIDI/midi_holder.dart';
import 'package:flutter_application_1/feature/MIDI/midi_manager.dart';

class DI {
  late final MidiHolder midiHolder;
  late final MidiManager midiManager;

  DI() {
    midiHolder = MidiHolder();
    midiManager = MidiManager(holder: midiHolder);
  }

  Future<void> init() async {
    await midiManager.getDevices();
  }
}

final di = DI();
