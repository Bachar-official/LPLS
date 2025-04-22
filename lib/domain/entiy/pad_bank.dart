import 'dart:io';

class PadBank {
  int audioIndex;
  int midiIndex;
  List<File> midiFiles;
  List<File> audioFiles;

  PadBank({
    required this.audioFiles,
    required this.audioIndex,
    required this.midiFiles,
    required this.midiIndex,
  });

  PadBank.initial()
    : audioFiles = [],
      audioIndex = 0,
      midiFiles = [],
      midiIndex = 0;

  void addFile(File file, bool isMidi) {
    if (isMidi) {
      midiFiles.add(file);
    } else {
      audioFiles.add(file);
    }
  }

  void trigger() {
    if (audioFiles.isNotEmpty && audioIndex < audioFiles.length) {
      print('Playing file #$audioIndex');
      if (audioIndex == audioFiles.length - 1) {
        audioIndex = 0;
      } else {
        audioIndex++;
      }
    } else if (midiFiles.isNotEmpty && midiIndex < midiFiles.length) {
      print('Playing file #$midiIndex');
      if (midiIndex == midiFiles.length - 1) {
        midiIndex = 0;
      } else {
        midiIndex++;
      }
    }
  }
}
