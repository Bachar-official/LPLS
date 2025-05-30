import 'package:flutter/services.dart';

class CursorService {

  static const _channel = MethodChannel('effect_cursor');

  /// Set cursor by filename (without .ico)
  static Future<void> setCursor(String name) async {
    try {
      await _channel.invokeMethod('setCursor', {'name': name});
    // ignore: empty_catches
    } catch(e) {}
  }

  /// Reset cursor to default
  static Future<void> resetCursor() async {
    try {
      await _channel.invokeMethod('resetCursor');
    // ignore: empty_catches
    } catch(e) {}
  }
}