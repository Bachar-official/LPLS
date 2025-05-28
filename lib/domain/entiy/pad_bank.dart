import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:lpls/domain/entiy/effect/effect.dart';
import 'package:lpls/domain/entiy/effect/effect_factory.dart';

class PadBank {
  int audioIndex;
  int midiIndex;
  List<File> midiFiles;
  List<File> audioFiles;
  late List<AudioPlayer> audioPlayers;
  late List<Effect> effects;

  PadBank({
    required this.audioFiles,
    required this.audioIndex,
    required this.midiFiles,
    required this.midiIndex,
    required this.audioPlayers,
    required this.effects,
  });

  PadBank.initial()
    : audioFiles = [],
      audioPlayers = [],
      audioIndex = 0,
      midiFiles = [],
      effects = [],
      midiIndex = 0;

  Effect? get currentEffect => effects.isEmpty ? null : effects[midiIndex];
  bool get isEmpty => midiFiles.isEmpty && audioFiles.isEmpty;

  Future<void> addFile(File file, bool isMidi) async {
    if (isMidi) {
      midiFiles.add(file);
      effects.add(await EffectFactory.readFile(file));
    } else {
      audioFiles.add(file);
      final player = AudioPlayer();
      await player.setSourceDeviceFile(file.path);
      audioPlayers.add(player);
    }
  }

  Future<PadBank> removeFile(int index, bool isMidi) async {
    if (isMidi) {
      if (index < 0 || index >= midiFiles.length) return this;
      final newMidi = List<File>.from(midiFiles)..removeAt(index);
      return await copyWith(midiFiles: newMidi, midiIndex: 0);
    } else {
      if (index < 0 || index >= audioFiles.length) return this;
      final newAudio = List<File>.from(audioFiles)..removeAt(index);
      return await copyWith(audioFiles: newAudio, audioIndex: 0);
    }
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
      if (newIndex > oldIndex) newIndex--;
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
      if (newIndex > oldIndex) newIndex--;
      newAudioFiles.insert(newIndex, file);

      return await copyWith(audioFiles: newAudioFiles);
    }
  }

  Future<PadBank> trigger() async {
    if (audioFiles.isNotEmpty && audioIndex < audioFiles.length) {
      await audioPlayers[audioIndex].resume();
      final newIndex = (audioIndex + 1) % audioPlayers.length;
      return await copyWith(audioIndex: newIndex);
    } else if (midiFiles.isNotEmpty && midiIndex < midiFiles.length) {
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

  Map<String, dynamic> serialize() => {
    'midiFiles': midiFiles.map((file) => file.path).toList(),
    'audioFiles': audioFiles.map((file) => file.path).toList(),
  };

  static Future<PadBank> deserialize(Map<String, dynamic> map) async {
    final midiField = 'midiFiles', audioField = 'audioFiles';
    if (map[midiField] == null) {
      throw Exception('Midi files is missing');
    } else if (map[audioField] == null) {
      throw Exception('Audio files is missing');
    } else {
      final midiFiles =
          (map[midiField] as List<dynamic>).map((file) => File(file)).toList();
      final audioFiles =
          (map[audioField] as List<dynamic>).map((file) => File(file)).toList();
      for (final file in [...midiFiles, ...audioFiles]) {
        if (!file.existsSync()) {
          throw Exception('${file.path} not exists');
        }
      }
      return await PadBank.initial().copyWith(
        midiFiles: midiFiles,
        audioFiles: audioFiles,
      );
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

    bool audioChanged = !identical(updatedAudioFiles, this.audioFiles);
    bool midiChanged = !identical(updatedMidiFiles, this.midiFiles);

    List<AudioPlayer> newAudioPlayers = audioPlayers;
    List<Effect> newEffects = effects;

    if (audioChanged) {
      newAudioPlayers = [];

      for (var file in updatedAudioFiles) {
        final existingIndex = this.audioFiles.indexWhere(
          (oldFile) => oldFile.path == file.path,
        );

        if (existingIndex != -1) {
          newAudioPlayers.add(audioPlayers[existingIndex]);
        } else {
          final player = AudioPlayer();
          await player.setSourceDeviceFile(file.path);
          newAudioPlayers.add(player);
        }
      }

      for (int i = 0; i < this.audioFiles.length; i++) {
        final oldPath = this.audioFiles[i].path;
        final isUsed = updatedAudioFiles.any((f) => f.path == oldPath);
        if (!isUsed) {
          await audioPlayers[i].dispose();
        }
      }
    }

    if (midiChanged) {
      newEffects = await Future.wait(
        updatedMidiFiles.map((file) => EffectFactory.readFile(file)),
      );
    }

    return PadBank(
      audioIndex: audioIndex ?? this.audioIndex,
      midiIndex: midiIndex ?? this.midiIndex,
      midiFiles: updatedMidiFiles,
      audioFiles: updatedAudioFiles,
      audioPlayers: newAudioPlayers,
      effects: newEffects,
    );
  }
}
