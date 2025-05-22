import 'dart:io';

import 'package:lpls/constants/file_types.dart';
import 'package:lpls/domain/enum/mode.dart';

abstract class FileExtensions {
  static const tempProject = 'lpp';
  static const effect = 'lpe';
  static const project = 'lpls';
  static const effectFileName = 'effect.$effect';
  static const tempProjectFileName = 'tempProject.$tempProject';
  static const projectFileName = 'project.$project';
}

void checkFileExtension(Mode mode, File file) {
  String extension = file.path.split('.').last;
  if (mode == Mode.audio && !audioFileTypes.contains(extension)) {
    throw Exception('Invalid file type. Only audio files are supported.');
  }
  if (mode == Mode.midi && extension != midiFileType) {
    throw Exception(
      'Invalid file type. In MIDI mode only LPE files supported.',
    );
    
  }
}
