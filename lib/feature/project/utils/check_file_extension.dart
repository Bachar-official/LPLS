import 'dart:io';

import 'package:lpls/constants/file_types.dart';

void checkFileExtension(File file) {
  String extension = file.path.split('.').last;
  if (!audioFileTypes.contains(extension)) {
    throw Exception('Invalid file type. Only audio files are supported.');
  }
}