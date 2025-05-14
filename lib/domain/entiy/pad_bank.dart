import 'dart:io';

import 'package:audioplayers/audioplayers.dart';

class PadBank {
  int audioIndex;
  int midiIndex;
  List<File> midiFiles;
  List<File> audioFiles;
  late List<AudioPlayer> audioPlayers;

  PadBank({
    required this.audioFiles,
    required this.audioIndex,
    required this.midiFiles,
    required this.midiIndex,
    required this.audioPlayers,
  });

  PadBank.initial()
    : audioFiles = [],
    audioPlayers = [],
      audioIndex = 0,
      midiFiles = [],
      midiIndex = 0;

  Future<void> addFile(File file, bool isMidi) async {
    if (isMidi) {
      midiFiles.add(file);
    } else {
      audioFiles.add(file);
      final player = AudioPlayer();
      await player.setSourceDeviceFile(file.path);
      audioPlayers.add(player);
    }
  }

  void reorderFiles(int oldIndex, int newIndex, {required bool isMidi}) {
  if (isMidi) {
    if (oldIndex < 0 || oldIndex >= midiFiles.length || newIndex < 0 || newIndex > midiFiles.length) return;
    final file = midiFiles.removeAt(oldIndex);
    midiFiles.insert(newIndex, file);
  } else {
    if (oldIndex < 0 || oldIndex >= audioFiles.length || newIndex < 0 || newIndex > audioFiles.length) return;
    final file = audioFiles.removeAt(oldIndex);
    final player = audioPlayers.removeAt(oldIndex);
    audioFiles.insert(newIndex, file);
    audioPlayers.insert(newIndex, player);
  }
}

  Future<void> trigger() async {
    print('TRIGGERED!!!');
    if (audioFiles.isNotEmpty && audioIndex < audioFiles.length) {
      print('Playing file #$audioIndex');
      audioPlayers[audioIndex].resume();
      audioIndex = (audioIndex + 1) % audioPlayers.length;
    } else if (midiFiles.isNotEmpty && midiIndex < midiFiles.length) {
      print('Playing file #$midiIndex');if (midiIndex == midiFiles.length - 1) {
        midiIndex = 0;
      } else {
        midiIndex++;
      }
      midiIndex = (midiIndex + 1) % midiFiles.length;
    }
  }

  void dispose() {
    for (var player in audioPlayers) {
      player.dispose();
    }
  }
}
