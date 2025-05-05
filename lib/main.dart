import 'package:flutter/material.dart';
import 'package:lpls/domain/app.dart';
import 'package:lpls/domain/di.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
   WindowOptions windowOptions = const WindowOptions(
    minimumSize: Size(800, 600),
    size: Size(1024, 768),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  await di.init();
  runApp(ProviderScope(child: App()));
}
