import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lpls/constants/pad_structure.dart';
import 'package:lpls/domain/entiy/entity.dart';
import 'package:lpls/domain/enum/enum.dart';
import 'package:lpls/feature/project/utils/check_file_extension.dart';
import 'package:lpls/utils/utils.dart';
import 'package:minisound/engine_flutter.dart';

class ProjectFileManager {
  final midiFilesField = 'midiFiles';
  final audioFilesField = 'audioFiles';
  String? projectPath;

  bool get isSaveAvailable => projectPath != null;

  ProjectFileManager() {
    projectPath = null;
  }

  Future<PadStructure> open(Engine engine, {String? path}) async {
    final result =
        path == null
            ? await FilePicker.platform.pickFiles(
              allowMultiple: false,
              type: FileType.custom,
              allowedExtensions: [FileExtensions.tempProject],
            )
            : null;

    final filePath = path ?? result?.files.single.path;

    if (filePath == null) {
      throw ConditionException(
        'file picker result is null',
        'Project open flow cancelled',
      );
    }

    projectPath = filePath;

    // Opening lpp and decoding
    final file = File(filePath);
    final jsonString = await file.readAsString();
    final Map<String, dynamic> decoded = jsonDecode(jsonString);

    final baseDir = FileUtils.getBasePath(filePath);

    // Filling banks
    final banks = <int, Map<Pad, PadBank>>{};
    for (final bankEntry in decoded.entries) {
      final page = int.parse(bankEntry.key);
      final padMap = <Pad, PadBank>{};

      for (final padEntry in (bankEntry.value as Map).entries) {
        final pad = Pad.values.firstWhere((p) => p.name == padEntry.key);
        final data = padEntry.value as Map;

        if (data[midiFilesField] == null) {
          throw Exception('No midi files field found');
        }
        if (data[audioFilesField] == null) {
          throw Exception('No midi files field found');
        }

        final midiPaths =
            (data[midiFilesField] as List).map((relPath) {
              return File('$baseDir/$relPath');
            }).toList();

        final audioPaths =
            (data[audioFilesField] as List).map((relPath) {
              return File('$baseDir/$relPath');
            }).toList();

        padMap[pad] = await PadBank.initial(
          engine,
        ).copyWith(midiFiles: midiPaths, audioFiles: audioPaths);
      }

      banks[page] = padMap;
    }
    return banks;
  }

  Future<void> saveProject(
    PadStructure structure, {
    bool saveAs = false,
  }) async {
    if (isPadStructureEmpty(structure)) {
      throw ConditionException('banks is empty', 'Project is empty');
    }
    String? pickerResult;
    if (projectPath == null || saveAs) {
      pickerResult = await FilePicker.platform.saveFile(
        dialogTitle: 'Save project',
        fileName: FileExtensions.tempProjectFileName,
      );
    }

    if (projectPath == null && pickerResult == null) {
      throw ConditionException(
        'file picker result is null',
        'Project save flow is cancelled',
      );
    }

    // Serializing project structure and saving at file
    final content = jsonEncode(PadStructureSerializer.serialize(structure));
    await File(
      saveAs ? pickerResult! : projectPath ?? pickerResult!,
    ).writeAsString(content);
  }

  Future<PadStructure> importProject(Engine engine) async {
    final pickerResult = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: [FileExtensions.project],
    );
    if (pickerResult == null) {
      throw ConditionException(
        'file picker result is null',
        'Project import flow is cancelled',
      );
    }

    final baseName =
        pickerResult.paths.last != null
            ? pickerResult.paths.last!
                .split(Platform.pathSeparator)
                .last
                .split('.')
                .first
            : 'project';

    final baseDirectory = FileUtils.getBasePath(pickerResult.paths.last!);
    await FileUtils.extractLpls(
      pickerResult.paths.last!,
      '$baseDirectory/$baseName',
    );

    return await open(engine, path: '$baseDirectory/$baseName/$baseName.lpp');
  }

  Future<void> exportProject(PadStructure structure) async {
    if (isPadStructureEmpty(structure)) {
      throw ConditionException('banks is empty', 'Project is empty!');
    }
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Export project to...',
      fileName: FileExtensions.projectFileName,
    );
    final baseName =
        path != null
            ? path.split(Platform.pathSeparator).last.split('.').first
            : 'project';

    // If no path selected
    if (path == null) {
      throw ConditionException(
        'file picker result is null',
        'Project export flow is cancelled',
      );
    }

    // Creating temp directories
    final tempDir = await Directory.systemTemp.createTemp('lpls_temp_');
    final effectsDir = Directory('${tempDir.path}/effects');
    final audioDir = Directory('${tempDir.path}/audio');
    await effectsDir.create(recursive: true);
    await audioDir.create(recursive: true);

    // Serializing project and copying files
    final serializedBanks = <String, Map<String, Map<String, List<String>>>>{};

    for (final bankEntry in structure.entries) {
      final bankIndex = bankEntry.key;
      final serializedPadMap = <String, Map<String, List<String>>>{};

      for (final padEntry in bankEntry.value.entries) {
        final pad = padEntry.key;
        final bank = padEntry.value;

        final updatedMidiPaths = <String>[];
        for (final file in bank.midiFiles) {
          final newPath = '${effectsDir.path}/${file.uri.pathSegments.last}';
          await file.copy(newPath);
          updatedMidiPaths.add('effects/${file.uri.pathSegments.last}');
        }

        final updatedAudioPaths = <String>[];
        for (final file in bank.audioFiles) {
          final newPath = '${audioDir.path}/${file.uri.pathSegments.last}';
          await file.copy(newPath);
          updatedAudioPaths.add('audio/${file.uri.pathSegments.last}');
        }

        serializedPadMap[pad.name] = {
          midiFilesField: updatedMidiPaths,
          audioFilesField: updatedAudioPaths,
        };
      }

      serializedBanks[bankIndex.toString()] = serializedPadMap;
    }

    // Writing lpp file and archiving at ZIP
    final projectJson = jsonEncode(serializedBanks);
    final lppFile = File('${tempDir.path}/$baseName.lpp');
    await lppFile.writeAsString(projectJson);

    final encoder = ZipEncoder();
    final archive = Archive();

    for (final entity in tempDir.listSync(recursive: true)) {
      if (entity is File) {
        final relativePath = entity.path.substring(tempDir.path.length + 1);
        final data = await entity.readAsBytes();
        archive.addFile(ArchiveFile(relativePath, data.length, data));
      }
    }

    final zipData = encoder.encode(archive);
    final outFile = File(path);
    await outFile.writeAsBytes(zipData);

    // Deleting temp dir and writing success message
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  }
}
