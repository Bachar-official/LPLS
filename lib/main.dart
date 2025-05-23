import 'package:flutter/material.dart';
import 'package:lpls/domain/app.dart';
import 'package:lpls/domain/di.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const ProviderScope(child: App()));
}
