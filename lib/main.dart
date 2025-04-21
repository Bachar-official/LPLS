import 'package:flutter/material.dart';
import 'package:flutter_application_1/domain/app.dart';
import 'package:flutter_application_1/domain/di.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  await di.init();
  runApp(ProviderScope(child: App()));
}
