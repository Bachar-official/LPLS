import 'dart:io';

import 'package:lpls/constants/file_types.dart';
import 'package:lpls/domain/enum/mode.dart';

void checkFileExtension(Mode mode, File file) {
  String extension = file.path.split('.').last;
  if (mode == Mode.audio && !audioFileTypes.contains(extension)) {
    throw Exception('Invalid file type. Only audio files are supported.');
  }
  if (mode == Mode.midi && extension != midiFileType) {
    throw Exception('Invalid file type. In MIDI mode only LPE files supported.');
  }
}