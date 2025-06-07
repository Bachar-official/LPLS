// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get file => 'Файл';

  @override
  String get screen => 'Экран';

  @override
  String get project => 'Проект';

  @override
  String get effect => 'Редактор эффекта';

  @override
  String get theme => 'Тема';

  @override
  String get theme_light => 'Светлая';

  @override
  String get theme_dark => 'Тёмная';

  @override
  String get theme_system => 'Системная';

  @override
  String get open => 'Открыть...';

  @override
  String get save => 'Сохранить';

  @override
  String get save_as => 'Сохранить как...';

  @override
  String get exit => 'Выйти';

  @override
  String get export => 'Экспортировать';

  @override
  String get import => 'Импортировать';

  @override
  String get effect_clear => 'Очистить эффект';

  @override
  String get locale => 'Язык';

  @override
  String get locale_en => 'English';

  @override
  String get locale_ru => 'Русский';

  @override
  String get no_device => 'Нет устройства';

  @override
  String current_page(int pageNumber) {
    return 'Текущая страница: $pageNumber';
  }

  @override
  String get select_midi => 'Выбрать устройство MIDI';

  @override
  String get no_devices => 'Устройства не найдены';

  @override
  String get audio => 'Аудио';

  @override
  String get midi => 'MIDI';

  @override
  String get no_connected =>
      'Нет подключённых устройств или соединено несовместимое устройство';

  @override
  String get no_effect => 'Нет эффекта';

  @override
  String frame_number(int frameNumber) {
    return 'Редкатор эффекта - кадр №$frameNumber';
  }

  @override
  String get no_effect_body =>
      'Эффекта пока нет\nПожалуйста, откройте существующий эффект или создайте первый кадр, нажав на кнопку \"+\"';

  @override
  String get no_frames => 'Нет кадров';

  @override
  String get no_files => 'Пока что нет файлов';

  @override
  String track_editor(String mode) {
    return 'Редактор трека ($mode)';
  }
}
