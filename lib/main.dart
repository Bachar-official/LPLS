import 'package:flutter/material.dart';
import 'package:lpls/domain/app.dart';
import 'package:lpls/domain/di.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  await di.init();
  runApp(ProviderScope(child: App()));
}
