import 'package:flutter/material.dart';
import 'package:lpls/domain/entiy/manager_deps.dart';
import 'package:lpls/feature/mobile_project/mobile_project_holder.dart';
import 'package:lpls/feature/mobile_project/mobile_project_manager.dart';
// ignore: depend_on_referenced_packages
import 'package:logger/logger.dart';

class MobileDI {
  late final MobileProjectHolder projectHolder;
  late final MobileProjectManager projectManager;

  final Logger logger = Logger();
  final GlobalKey<ScaffoldMessengerState> scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  late final MobileManagerDeps deps;

  MobileDI() {
    deps = (logger: logger, scaffoldKey: scaffoldKey);

    projectHolder = MobileProjectHolder();
    projectManager = MobileProjectManager(holder: projectHolder, deps: deps);
  }

  Future<void> init() async {
      logger.d('Initializing mobile DI...');
      await projectManager.getDevices();
  }
}

final mobileDI = MobileDI();