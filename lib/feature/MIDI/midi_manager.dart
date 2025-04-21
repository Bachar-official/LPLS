import 'package:flutter/material.dart' hide Velocity;
import 'package:flutter/services.dart';
import 'package:flutter_application_1/domain/entiy/mode.dart';
import 'package:flutter_application_1/domain/entiy/velocity.dart';
import 'package:flutter_application_1/feature/MIDI/midi_holder.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';

//TODO: режимы на ланчпаде не нужны, только в программе. Воспроизводиться всё будет сразу.
class MidiManager {
  final MidiHolder holder;
  final MidiCommand midi = MidiCommand();

  MidiManager({required this.holder});

  Future<void> getDevices() async {
    await disconnect();
    final devices = await midi.devices ?? [];
    holder.setDevices(devices);
  }

  Future<void> setDevice(MidiDevice? device) async {
    holder.setDevice(device);
    if (device != null) {
      await midi.connectToDevice(device);
      midi.onMidiDataReceived?.listen(_handleMidiMessage);
    }
  }

  void _handleMidiMessage(MidiPacket event) {
    int coords = event.data[1];
    print(coords);
    // Check if change page button pressed
    if (coords % 10 == 9 && coords < 100) {
      holder.setPage((89 - coords) ~/ 10);
    } else if (coords == 109 || coords == 110) {
      // Checking pressing "User 1" and "User 2" buttons
      holder.setMode(Mode.fromCoords(coords));
    }
  }

  Future<void> disconnect() async {
    if (holder.rState.device != null) {
      midi.disconnectDevice(holder.rState.device!);
      holder.setDevice(null);
    }
  }
}
