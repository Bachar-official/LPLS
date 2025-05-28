import 'package:flutter/material.dart';
import 'package:lpls/domain/app/app.dart';
import 'package:lpls/domain/app/mobile_app.dart';
import 'package:lpls/domain/di/di.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lpls/domain/di/mobile_di.dart';
import 'package:lpls/utils/platform_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (PlatformUtils.isMobile) {
    await mobileDI.init();
    runApp(const ProviderScope(child: MobileApp()));
  } else if (PlatformUtils.isDesktop) {
    await di.init();
    runApp(const ProviderScope(child: App()));
  } else {
    throw UnimplementedError('Unsupported platform');
  }
}
