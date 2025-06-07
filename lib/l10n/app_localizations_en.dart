// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get file => 'File';

  @override
  String get screen => 'Screen';

  @override
  String get project => 'Project';

  @override
  String get effect => 'Effect editor';

  @override
  String get theme => 'Theme';

  @override
  String get theme_light => 'Light';

  @override
  String get theme_dark => 'Dark';

  @override
  String get theme_system => 'System';

  @override
  String get open => 'Open...';

  @override
  String get save => 'Save';

  @override
  String get save_as => 'Save as...';

  @override
  String get exit => 'Exit';

  @override
  String get export => 'Export';

  @override
  String get import => 'Import';

  @override
  String get effect_clear => 'Clear effect';

  @override
  String get locale => 'Language';

  @override
  String get locale_en => 'English';

  @override
  String get locale_ru => 'Русский';

  @override
  String get no_device => 'No device';

  @override
  String current_page(int pageNumber) {
    return 'Current page: $pageNumber';
  }

  @override
  String get select_midi => 'Select MIDI Device';

  @override
  String get no_devices => 'Devices not found';

  @override
  String get audio => 'Audio';

  @override
  String get midi => 'MIDI';

  @override
  String get no_connected =>
      'No devices connected or incompatible device connected';

  @override
  String get no_effect => 'No effect';

  @override
  String frame_number(int frameNumber) {
    return 'Effect editor - frame #$frameNumber';
  }

  @override
  String get no_effect_body =>
      'There is no effect yet.\nPlease edit effect from Project screen, or create one by clicking on the \"+\" icon.';

  @override
  String get no_frames => 'No frames for this effect';

  @override
  String get no_files => 'No files attached yet';

  @override
  String track_editor(String mode) {
    return 'Track editor ($mode)';
  }
}
