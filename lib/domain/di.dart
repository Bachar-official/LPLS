import 'package:flutter/material.dart';
import 'package:lpls/domain/entiy/manager_deps.dart';
import 'package:lpls/feature/MIDI/midi_holder.dart';
import 'package:lpls/feature/MIDI/midi_manager.dart';
// ignore: depend_on_referenced_packages
import 'package:logger/logger.dart';

class DI {
  late final MidiHolder midiHolder;
  late final MidiManager midiManager;
  final Logger logger = Logger();
  final GlobalKey<ScaffoldMessengerState> scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  late final ManagerDeps deps;

  DI() {
    deps = (logger: logger, scaffoldKey: scaffoldKey);
    midiHolder = MidiHolder();
    midiManager = MidiManager(holder: midiHolder, deps: deps);
  }

  Future<void> init() async {
    await midiManager.getDevices();
  }
}

final di = DI();
