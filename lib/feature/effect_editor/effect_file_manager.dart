import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
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

  Future<Effect<LPColor>> open({String? effectPath}) async {
    FilePickerResult? result;
    if (effectPath == null) {
      result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: [FileExtensions.effect],
      );
    }

    if (effectPath == null && result == null) {
      throw ConditionException(
        'picker result is null',
        'Effect open flow is cancelled',
      );
    }
    final file = File(effectPath ?? result!.files.first.path!);
    final effect = await EffectFactory.readFile(file);
    effectPath = effectPath ?? result!.files.first.path!;
    return effect;
  }

  Future<void> save(Effect<LPColor>? effect, {bool saveAs = false}) async {
    if (effect == null || effect.frames.isEmpty) {
      throw ConditionException('effect is null', 'Effect is empty');
    }
    String? pickerResult;
    if (effectPath == null || saveAs) {
      pickerResult = await FilePicker.platform.saveFile(
        dialogTitle: 'Select output file',
        fileName: FileExtensions.effectFileName,
      );
    }

    if (effectPath == null && pickerResult == null) {
      throw ConditionException(
        'No effect to save',
        'Effect save flow cancelled',
      );
    }

    if (effect is Effect<ColorMk1>) {
      final map = Mk1EffectSerializer().toMap(
        effect,
        bpm: BpmUtils.millisToBpm(effect.frameTime, effect.beats),
        palette: 'mk1',
      );
      await File(
        saveAs ? pickerResult! : effectPath ?? pickerResult!,
      ).writeAsString(jsonEncode(map));
    } else {
      final map = Mk2EffectSerializer().toMap(
        effect as Effect<ColorMk2>,
        bpm: BpmUtils.millisToBpm(effect.frameTime, effect.beats),
        palette: 'mk2',
      );
      await File(
        saveAs ? pickerResult! : effectPath ?? pickerResult!,
      ).writeAsString(jsonEncode(map));
    }
  }
}
