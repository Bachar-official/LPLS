import 'dart:convert';
import 'dart:io';
import 'dart:typed_data'; // <-- ДОБАВЛЕНО для Uint8List

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
    projectPath = path;

    if (projectPath == null) {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: [FileExtensions.tempProject],
      );

      if (file == null || file.path == null) {
        throw ConditionException(
          'file picker result is null',
          'Project open flow cancelled',
        );
      }
      projectPath = file.path;
    }

    final projectFile = File(projectPath!);
    final jsonString = await projectFile.readAsString();
    final Map<String, dynamic> decoded = jsonDecode(jsonString);

    final baseDir = FileUtils.getBasePath(projectPath!);
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
          throw Exception('No audio files field found');
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

    final content = jsonEncode(PadStructureSerializer.serialize(structure));
    // ИСПРАВЛЕНО: Явное преобразование List<int> в Uint8List
    final Uint8List bytes = Uint8List.fromList(utf8.encode(content));

    if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
      await FileSaver.instance.saveFile(
        name: 'project',
        bytes: bytes,
        fileExtension: FileExtensions.tempProject.replaceAll('.', ''),
        mimeType: MimeType.other,
      );
      projectPath = null;
    } else {
      final uri = await FilePicker.saveFile(
        dialogTitle: 'Save project',
        fileName: FileExtensions.tempProjectFileName,
        bytes: bytes,
      );

      if (uri == null) {
        throw ConditionException(
          'file picker result is null',
          'Project save flow is cancelled',
        );
      }

      projectPath = uri.toFilePath();
    }
  }

  Future<PadStructure> importProject(Engine engine) async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: [FileExtensions.project],
    );

    if (file == null || file.path == null) {
      throw ConditionException(
        'file picker result is null',
        'Project import flow is cancelled',
      );
    }

    final filePath = file.path!;
    final baseName =
        filePath.split(Platform.pathSeparator).last.split('.').first;
    final baseDirectory = FileUtils.getBasePath(filePath);

    await FileUtils.extractLpls(filePath, '$baseDirectory/$baseName');

    return await open(
      engine,
      path:
          '$baseDirectory${Platform.pathSeparator}$baseName${Platform.pathSeparator}$baseName.lpp',
    );
  }

  Future<void> exportProject(PadStructure structure) async {
    if (isPadStructureEmpty(structure)) {
      throw ConditionException('banks is empty', 'Project is empty!');
    }

    final baseName = 'project';
    final tempDir = await Directory.systemTemp.createTemp('lpls_temp_');
    final effectsDir = Directory('${tempDir.path}/effects');
    final audioDir = Directory('${tempDir.path}/audio');
    await effectsDir.create(recursive: true);
    await audioDir.create(recursive: true);

    final serializedBanks = <String, Map<String, Map<String, List<String>>>>{};

    for (final bankEntry in structure.entries) {
      final bankIndex = bankEntry.key;
      final serializedPadMap = <String, Map<String, List<String>>>{};

      for (final padEntry in bankEntry.value.entries) {
        final pad = padEntry.key;
        final bank = padEntry.value;

        final updatedMidiPaths = <String>[];
        for (final midiFile in bank.midiFiles) {
          final newPath =
              '${effectsDir.path}/${midiFile.uri.pathSegments.last}';
          await midiFile.copy(newPath);
          updatedMidiPaths.add('effects/${midiFile.uri.pathSegments.last}');
        }

        final updatedAudioPaths = <String>[];
        for (final audioFile in bank.audioFiles) {
          final newPath = '${audioDir.path}/${audioFile.uri.pathSegments.last}';
          await audioFile.copy(newPath);
          updatedAudioPaths.add('audio/${audioFile.uri.pathSegments.last}');
        }

        serializedPadMap[pad.name] = {
          midiFilesField: updatedMidiPaths,
          audioFilesField: updatedAudioPaths,
        };
      }
      serializedBanks[bankIndex.toString()] = serializedPadMap;
    }

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

    // ИСПРАВЛЕНО: Безопасная обработка nullable List<int> и конвертация в Uint8List
    final List<int> encodedZip = encoder.encode(archive);
    final Uint8List zipBytes = Uint8List.fromList(encodedZip);

    if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
      await FileSaver.instance.saveFile(
        name: baseName,
        bytes: zipBytes, // ИСПРАВЛЕНО: убран лишний '!', тип теперь точный
        fileExtension: FileExtensions.project.replaceAll('.', ''),
        mimeType: MimeType.other,
      );
    } else {
      final uri = await FilePicker.saveFile(
        dialogTitle: 'Export project to...',
        fileName: '$baseName.${FileExtensions.project}',
        bytes: zipBytes, // ИСПРАВЛЕНО: убран лишний '!', тип теперь точный
      );

      if (uri == null) {
        throw ConditionException(
          'file picker result is null',
          'Project export flow is cancelled',
        );
      }
    }

    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  }
}
