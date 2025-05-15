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

  Future<List<AudioPlayer>> _cachePlayers() async {
    return audioFiles.map((file) {
      final player = AudioPlayer();
      player.setSourceDeviceFile(file.path);
      return player;
    }).toList();
  }

  Future<PadBank> reorderFiles(
    int oldIndex,
    int newIndex, {
    required bool isMidi,
  }) async {
    if (isMidi) {
      if (oldIndex < 0 ||
          oldIndex >= midiFiles.length ||
          newIndex < 0 ||
          newIndex > midiFiles.length) {
        return this;
      }

      final newMidiFiles = List<File>.from(midiFiles);
      final file = newMidiFiles.removeAt(oldIndex);
      newMidiFiles.insert(newIndex, file);

      return await copyWith(midiFiles: newMidiFiles);
    } else {
      if (oldIndex < 0 ||
          oldIndex >= audioFiles.length ||
          newIndex < 0 ||
          newIndex > audioFiles.length) {
        return this;
      }

      final newAudioFiles = List<File>.from(audioFiles);
      final file = newAudioFiles.removeAt(oldIndex);
      newAudioFiles.insert(newIndex, file);

      return await copyWith(audioFiles: newAudioFiles);
    }
  }

  Future<PadBank> trigger() async {
    // TODO: re-update cache?
    print('TRIGGERED!!!');

    if (audioFiles.isNotEmpty && audioIndex < audioFiles.length) {
      print('Playing file #$audioIndex');
      await audioPlayers[audioIndex].resume();
      final newIndex = (audioIndex + 1) % audioPlayers.length;
      return await copyWith(audioIndex: newIndex);
    } else if (midiFiles.isNotEmpty && midiIndex < midiFiles.length) {
      print('Playing file #$midiIndex');
      final newIndex = (midiIndex + 1) % midiFiles.length;
      return await copyWith(midiIndex: newIndex);
    }

    return this;
  }

  void dispose() {
    for (var player in audioPlayers) {
      player.dispose();
    }
  }

  Future<PadBank> copyWith({
    int? audioIndex,
    int? midiIndex,
    List<File>? midiFiles,
    List<File>? audioFiles,
  }) async {
    final updatedAudioFiles = audioFiles ?? this.audioFiles;
    final updatedMidiFiles = midiFiles ?? this.midiFiles;

    // Если аудиофайлы изменились — пересоздаём плееры и очищаем старые
    List<AudioPlayer> newAudioPlayers;
    if (!identical(updatedAudioFiles, this.audioFiles)) {
      // Освобождаем текущие плееры
      for (var player in audioPlayers) {
        await player.dispose();
      }
      // Кэшируем новые плееры
      newAudioPlayers = await Future.wait(
        updatedAudioFiles.map((file) async {
          final player = AudioPlayer();
          await player.setSourceDeviceFile(file.path);
          return player;
        }),
      );
    } else {
      // Не изменялись — используем старые плееры
      newAudioPlayers = audioPlayers;
    }

    return PadBank(
      audioIndex: audioIndex ?? this.audioIndex,
      midiIndex: midiIndex ?? this.midiIndex,
      midiFiles: updatedMidiFiles,
      audioFiles: updatedAudioFiles,
      audioPlayers: newAudioPlayers,
    );
  }
}
