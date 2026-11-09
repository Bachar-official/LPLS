import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:lpls/constants/constants.dart';
import 'package:lpls/domain/entiy/entity.dart';
import 'package:lpls/domain/enum/enum.dart';
import 'package:lpls/feature/mobile_project/mobile_project_holder.dart';
import 'package:lpls/feature/mobile_project/mobile_project_state.dart';
import 'package:lpls/utils/utils.dart';
import 'package:path_provider/path_provider.dart';

class MobileProjectManager {
  final MobileProjectHolder holder;
  final MobileManagerDeps deps;
  final MidiCommand midi = MidiCommand();
  StreamSubscription<MidiDataReceivedEvent>? _midiSubscription;

  bool get isConnected => holder.rState.device != null;

  MobileProjectManager({required this.holder, required this.deps});

  MobileProjectState get state => holder.rState;

  void setLoading(bool isLoading) => holder.setIsLoading(isLoading);

  Future<void> disconnect() async {
    mobileDebug(deps, 'Disconnecting from device ${state.device}');
    _midiSubscription?.cancel();
    if (state.device != null) {
      midi.disconnectDevice(state.device!);
      holder.setDevice(null, midi);
    }
  }

  Future<void> getDevices() async {
    await disconnect();
    setLoading(true);
    try {
      mobileDebug(deps, 'Try to get MIDI devices list');
      final devices = await midi.devices ?? [];
      for (var device in devices) {
        mobileDebug(deps, '${device.name}, ${device.id}, ${device.type}');
      }
      holder.setDevices(devices);
      mobileSuccess(deps, 'Got ${devices.length} devices');
    } catch (e, s) {
      mobileCatchException(
        deps,
        e,
        stackTrace: s,
        description: 'Error while getting MIDI devices list: ',
      );
    } finally {
      setLoading(false);
    }
  }

  Future<void> setDevice(MidiDevice? device) async {
    mobileDebug(
      deps,
      'Trying to set device to ${device?.name ?? 'Unnamed device'}',
    );
    _midiSubscription?.cancel();
    holder.setDevice(device, midi);
    if (device != null) {
      await midi.connectToDevice(device);
      final stream = state.lpDevice?.midi.onMidiDataReceived;
      if (stream == null) {
        mobileWarning(
          deps,
          'No stream from device',
          scaffoldMessage: 'Error while getting MIDI commands from device',
        );
        return;
      }
      _midiSubscription = stream.listen(_handleMidiMessage);
      mobileSuccess(deps, 'Device set to ${state.lpDevice}');
    }
  }

  void _handleMidiMessage(MidiDataReceivedEvent event) async {
    if (event.message.data[2] == 127) {
      var pressedPad = state.lpDevice?.pressedPad(event.message.data[1]);
      mobileDebug(deps, 'Pressed pad: ${pressedPad?.name}');

      if (managingPads.contains(pressedPad)) {
        holder.setPage(pressedPad);
      } else {
        var bank = state.banks[state.page]?[pressedPad];
        if (bank != null) {
          try {
            Pad pad = pressedPad!;
            state.lpDevice?.playEffect(bank.currentEffect);
            var newBank = await bank.trigger();
            final updatedPageBanks = {
              ...state.banks[state.page]!,
              pad: newBank,
            };
            final updatedBanks = {...state.banks, state.page: updatedPageBanks};
            holder.setBanks(updatedBanks);
          } catch (e, s) {
            mobileCatchException(deps, e, stackTrace: s);
          }
        }
      }
      mobileDebug(deps, 'Event in ${event.message.data}');
    }
  }

  /// === ИСПРАВЛЕННАЯ ЛОГИКА ОТКРЫТИЯ ===
  Future<void> importProject() async {
    mobileDebug(deps, 'Try to import project');
    setLoading(true);
    try {
      final result = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['lpls', 'lpp'],
      );

      if (result == null || result.path == null) {
        mobileWarning(
          deps,
          'file pick result is null',
          scaffoldMessage: 'There is no project to open',
        );
        return;
      }

      final filePath = result.path!;
      final fileName = filePath.split(Platform.pathSeparator).last;

      // ИСПРАВЛЕНИЕ 1: Используем постоянную директорию приложения, а не временную.
      // ОС не удалит эти файлы во время выступления.
      final appDir = await getApplicationDocumentsDirectory();
      final projectDir = Directory('${appDir.path}/lpls_current_project');

      if (await projectDir.exists()) {
        await projectDir.delete(recursive: true);
      }
      await projectDir.create(recursive: true);

      if (fileName.endsWith('.lpls')) {
        await FileUtils.extractLpls(filePath, projectDir.path);
      } else {
        // Если вдруг выбрали .lpp, просто копируем его (ассеты должны быть рядом)
        await File(filePath).copy('${projectDir.path}/$fileName');
      }

      // ИСПРАВЛЕНИЕ 2: Ищем .lpp файл динамически.
      // Имя файла внутри архива может не совпадать с именем самого архива.
      final lppFiles =
          await projectDir
              .list(recursive: true)
              .where((e) => e.path.endsWith('.lpp'))
              .toList();

      if (lppFiles.isEmpty) {
        throw Exception('No .lpp file found in project');
      }

      final lppPath = lppFiles.first.path;
      await _loadProjectFromFile(lppPath);
    } catch (e, s) {
      mobileCatchException(deps, e, stackTrace: s);
    } finally {
      setLoading(false);
    }
  }

  Future<void> openProject({String? path}) async {
    if (path != null) {
      await _loadProjectFromFile(path);
    } else {
      // Если путь не передан, запускаем стандартный процесс выбора и импорта
      await importProject();
    }
  }

  /// Вынесенная логика чтения JSON и инициализации банков
  Future<void> _loadProjectFromFile(String filePath) async {
    mobileDebug(deps, 'Trying to open project from file: $filePath');
    setLoading(true);
    try {
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final Map<String, dynamic> decoded = jsonDecode(jsonString);

      final baseDir = FileUtils.getBasePath(filePath);

      final banks = <int, Map<Pad, PadBank>>{};
      for (final bankEntry in decoded.entries) {
        final page = int.parse(bankEntry.key);
        final padMap = <Pad, PadBank>{};

        for (final padEntry in (bankEntry.value as Map).entries) {
          final pad = Pad.values.firstWhere((p) => p.name == padEntry.key);
          final data = padEntry.value as Map;

          final midiPaths =
              (data['midiFiles'] as List).map((relPath) {
                return File('$baseDir/$relPath');
              }).toList();

          final audioPaths =
              (data['audioFiles'] as List).map((relPath) {
                return File('$baseDir/$relPath');
              }).toList();

          // ИСПРАВЛЕНИЕ 3: Используем holder.engine вместо di.audioEngine.
          // di.audioEngine — это десктопный инстанс, на мобилке он не инициализирован корректно.
          padMap[pad] = await PadBank.initial(
            holder.engine,
          ).copyWith(midiFiles: midiPaths, audioFiles: audioPaths);
        }
        banks[page] = padMap;
      }

      holder.setBanks(banks);
      mobileSuccess(deps, 'Project opened');
    } catch (e, s) {
      mobileCatchException(deps, e, stackTrace: s);
    } finally {
      setLoading(false);
    }
  }

  Future<void> checkLights() async {
    mobileDebug(deps, 'Try to check lights');
    try {
      for (final pad in Pad.regularPads) {
        state.lpDevice?.sendCheckSignal(pad);
      }
      await Future.delayed(const Duration(seconds: 2), () {
        for (final pad in Pad.regularPads) {
          state.lpDevice?.sendCheckSignal(pad, stop: true);
        }
      });
    } catch (e, s) {
      mobileCatchException(deps, e, stackTrace: s);
    }
  }
}
