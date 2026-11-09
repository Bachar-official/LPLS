import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:lpls/feature/project/utils/check_file_extension.dart';
import 'package:lpls/domain/entiy/entity.dart';
import 'package:lpls/domain/enum/enum.dart';
import 'package:lpls/utils/bpm_utils.dart';

class EffectFileManager {
  String? effectPath;

  EffectFileManager() {
    effectPath = null;
  }

  void clear() => effectPath = null;

  Future<Effect<LPColor>> open({String? path}) async {
    effectPath = path;

    if (effectPath == null) {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: [FileExtensions.effect],
      );

      if (file == null || file.path == null) {
        throw ConditionException(
          'picker result is null',
          'Effect open flow is cancelled',
        );
      }
      effectPath = file.path;
    }

    final effectFile = File(effectPath!);
    final effect = await EffectFactory.readFile(effectFile);
    return effect;
  }

  Future<void> save(Effect<LPColor>? effect, {bool saveAs = false}) async {
    if (effect == null || effect.frames.isEmpty) {
      throw ConditionException('effect is null', 'Effect is empty');
    }

    final fileName = FileExtensions.effectFileName.replaceAll('.lpe', '');
    final bytes = _serializeEffect(effect);

    // === МОБИЛЬНЫЕ ПЛАТФОРМЫ И ВЕБ ===
    if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: bytes,
        fileExtension: 'lpe', // <-- ИСПРАВЛЕНО: было 'ext'
        mimeType: MimeType.other,
      );
      // На мобильных ОС сбрасываем путь, так как прямой доступ к файлу для
      // последующего "Save" ограничен песочницей.
      effectPath = null;
    }
    // === ДЕСКТОП (Windows, Linux, macOS) ===
    else {
      // В новых версиях file_picker saveFile сам записывает байты и возвращает Uri
      final uri = await FilePicker.saveFile(
        dialogTitle: 'Select output file',
        fileName: FileExtensions.effectFileName,
        bytes: bytes, // <-- ИСПРАВЛЕНО: теперь обязательный параметр
      );

      if (uri == null) {
        throw ConditionException(
          'No effect to save',
          'Effect save flow cancelled',
        );
      }

      // Сохраняем путь для будущих операций "Save" (без saveAs)
      effectPath = uri.toFilePath();
    }
  }

  Uint8List _serializeEffect(Effect<LPColor> effect) {
    if (effect is Effect<ColorMk1>) {
      final map = Mk1EffectSerializer().toMap(
        effect,
        bpm: BpmUtils.millisToBpm(effect.frameTime, effect.beats),
        palette: 'mk1',
      );
      return utf8.encode(jsonEncode(map));
    } else {
      final map = Mk2EffectSerializer().toMap(
        effect as Effect<ColorMk2>,
        bpm: BpmUtils.millisToBpm(effect.frameTime, effect.beats),
        palette: 'mk2',
      );
      return utf8.encode(jsonEncode(map));
    }
  }
}
