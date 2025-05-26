import 'dart:io';

import 'package:archive/archive.dart';

abstract class FileUtils {
  static String getBasePath(String path) {
    final arr = path.split(Platform.pathSeparator);
    return arr.getRange(0, arr.length - 1).join(Platform.pathSeparator);
  }

  static Future<void> extractLpls(String archivePath, String outputDir) async {
    final bytes = await File(archivePath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    for (final file in archive) {
      final filePath = '$outputDir/${file.name}';
      if (file.isFile) {
        final outFile = File(filePath);
        await outFile.create(recursive: true);
        await outFile.writeAsBytes(file.content as List<int>);
      } else {
        await Directory(filePath).create(recursive: true);
      }
    }
  }
}
