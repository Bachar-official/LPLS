import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lpls/constants/pad_structure.dart';
import 'package:lpls/constants/paging_pads.dart';
import 'package:lpls/domain/entiy/effect/effect.dart';
import 'package:lpls/domain/entiy/effect/effect_factory.dart';
import 'package:lpls/domain/entiy/effect/generated/line_effect.dart';
import 'package:lpls/domain/entiy/manager_deps.dart';
import 'package:lpls/domain/entiy/pad_bank.dart';
import 'package:lpls/domain/enum/brightness.dart';
import 'package:lpls/domain/enum/color_mk2.dart';
import 'package:lpls/domain/enum/mode.dart';
import 'package:lpls/domain/enum/color_mk1.dart';
import 'package:lpls/domain/enum/pad.dart';
import 'package:lpls/feature/MIDI/midi_holder.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:lpls/feature/MIDI/midi_state.dart';
import 'package:lpls/utils/ui_utils.dart';

class MidiManager {
  final MidiHolder holder;
  final ManagerDeps deps;
  final MidiCommand midi = MidiCommand();
  final TextEditingController vText = TextEditingController();
  bool get isConnected => holder.rState.device != null;

  MidiManager({required this.holder, required this.deps});

  void setLoading(bool isLoading) => holder.setIsLoading(isLoading);
  MidiState get state => holder.rState;

  Future<void> getDevices() async {
    await disconnect();
    setLoading(true);
    try {
      debug(deps, 'Try to get MIDI devices list');
      final devices = await midi.devices ?? [];
      for (var device in devices) {
        debug(deps, '${device.name}, ${device.id}, ${device.type}');
      }
      holder.setDevices(devices);
      success(deps, 'Got ${devices.length} devices');
    } catch (e, s) {
      catchException(
        deps,
        e,
        stackTrace: s,
        description: 'Error while getting MIDI devices list: ',
      );
    } finally {
      setLoading(false);
    }
  }

  Future<void> setDevice(MidiDevice? device) async {
    holder.setDevice(device, midi);
    debug(deps, 'Device is ${holder.rState.lpDevice}');
    if (device != null) {
      await midi.connectToDevice(device);
      holder.rState.lpDevice?.midi.onMidiDataReceived?.listen(
        _handleMidiMessage,
      );
    }
  }

  void _handleMidiMessage(MidiPacket event) {
    // debug(deps, 'event ${event.data}');
    // If event in "Note ON"
    if (event.data[2] == 127) {
      var pressedPad = holder.rState.lpDevice?.pressedPad(event.data[1]);
      debug(deps, 'Pressed pad: ${pressedPad?.name}');
      // Check if change page button pressed
      if (managingPads.contains(pressedPad)) {
        holder.setPage(pressedPad);
      } else {
        var bank = state.banks[state.page]?[pressedPad];
        if (bank != null) {
          bank.trigger();
        }
      }
    }
  }

  void setMode(Set<Mode> modes) => holder.setMode(modes.first);

  Future<void> disconnect() async {
    if (holder.rState.device != null) {
      midi.disconnectDevice(holder.rState.device!);
      holder.setDevice(null, midi);
    }
  }

  void sendCheckSignal(Pad pad, {bool stop = false}) =>
      holder.rState.lpDevice?.sendCheckSignal(pad, stop: stop);

  void addFileToPad(int page, Pad pad, File file, {required bool isMidi}) async {
    setLoading(true);
    final oldBank = holder.rState.banks[page]?[pad];
    if (oldBank == null) return;

    final newBank = PadBank(
      audioFiles: [...oldBank.audioFiles],
      audioPlayers: [...oldBank.audioPlayers],
      midiFiles: [...oldBank.midiFiles],
      audioIndex: oldBank.audioIndex,
      midiIndex: oldBank.midiIndex,
    );

    await newBank.addFile(file, isMidi);

    final newBanks = PadStructure.from(holder.rState.banks);
    final pageBanks = Map<Pad, PadBank>.from(newBanks[page] ?? {});
    pageBanks[pad] = newBank;
    newBanks[page] = pageBanks;

    holder.setBanks(newBanks);
    setLoading(false);
  }

  void foo() async {
    // const effect = Effect<ColorMk1>(frameTime: 250, beats: 2, frames: [
    //   {
    //     Pad.a1: (ColorMk1.red, Btness.light),
    //   },
    //   {
    //     Pad.a8: (ColorMk1.red, Btness.light),
    //     Pad.a1: (ColorMk1.off, Btness.dark),
    //   },
    //   {
    //     Pad.h8: (ColorMk1.red, Btness.light),
    //     Pad.a8: (ColorMk1.off, Btness.dark),
    //   },
    //   {
    //     Pad.h1: (ColorMk1.red, Btness.light),
    //     Pad.h8: (ColorMk1.off, Btness.dark),
    //   },
    //   {
    //     Pad.h1: (ColorMk1.off, Btness.dark),
    //   }
    // ]);
    final effect = LineEffect<ColorMk2>(from: Pad.a1, to: Pad.d8).getEffect(ColorMk2.green);
    // debug(deps, EffectFactory.toJson(effect, palette: 'mk2'));
    if (isConnected) {
      holder.rState.lpDevice?.playEffect(effect);
    }
  }
}
