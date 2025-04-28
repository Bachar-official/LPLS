import 'dart:io';

import 'package:lpls/constants/pad_structure.dart';
import 'package:lpls/domain/entiy/launchpad/launchpad_device.dart';
import 'package:lpls/domain/entiy/launchpad/launchpad_factory.dart';
import 'package:lpls/domain/enum/mode.dart';
import 'package:lpls/domain/enum/pad.dart';
import 'package:lpls/feature/MIDI/midi_state.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MidiHolder extends StateNotifier<MidiState> {
  MidiHolder() : super(MidiState.initial());

  MidiState get rState => super.state;

  void setDevice(MidiDevice? device, MidiCommand midi) {
    if (device == null) {
      state = state.copyWith(device: null, nullableDevice: true, lpDevice: null, nullableLpDevice: true);
    } else {
      state = state.copyWith(device: device, lpDevice: LaunchpadFactory.create(midi: midi, device: device));
    }
  }

  void setDevices(List<MidiDevice> devices) {
    state = state.copyWith(devices: devices);
  }

  void setPage(Pad? pad) {
    int page = 0;
    switch(pad) {
      case Pad.h: page = 7; break;
      case Pad.g: page = 6; break;
      case Pad.f: page = 5; break;
      case Pad.e: page = 4; break;
      case Pad.d: page = 3; break;
      case Pad.c: page = 2; break;
      case Pad.b: page = 1; break;
      case Pad.a: default : page = 0; break;
    }
    state = state.copyWith(page: page);
  }

  void setMode(Mode mode) {
    state = state.copyWith(mode: mode);
  }

  void setIsLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void setBanks(PadStructure banks) {
    state = state.copyWith(banks: banks);
  }
}
