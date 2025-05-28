import 'dart:io';

import 'package:flutter/foundation.dart';

abstract class PlatformUtils {
  static bool get isDesktop => Platform.isLinux || Platform.isWindows;
  static bool get isMobile => Platform.isAndroid;
  static bool get isUnsupported => Platform.isFuchsia || Platform.isIOS || Platform.isMacOS || kIsWeb || kIsWasm;
}