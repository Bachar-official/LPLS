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
      await player.setSourceAsset('audio/kick.mp3');
      audioPlayers.add(player);
    }
  }

  Future<void> trigger() async {
    print('TRIGGERED!!!');
    AudioPlayer().play(AssetSource('audio/kick.mp3'));
    if (audioFiles.isNotEmpty && audioIndex < audioFiles.length) {
      print('Playing file #$audioIndex');
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
