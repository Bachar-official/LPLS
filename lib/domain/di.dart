import 'package:flutter/material.dart';
import 'package:lpls/domain/entiy/manager_deps.dart';
import 'package:lpls/feature/home/home_holder.dart';
import 'package:lpls/feature/home/home_manager.dart';
import 'package:lpls/feature/project/project_holder.dart';
import 'package:lpls/feature/project/project_manager.dart';
// ignore: depend_on_referenced_packages
import 'package:logger/logger.dart';

class DI {
  late final ProjectHolder projectHolder;
  late final ProjectManager projectManager;

  late final HomeHolder homeHolder;
  late final HomeManager homeManager;

  final Logger logger = Logger();
  final GlobalKey<ScaffoldMessengerState> scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  late final ManagerDeps deps;

  DI() {
    deps = (logger: logger, scaffoldKey: scaffoldKey);
    projectHolder = ProjectHolder();
    projectManager = ProjectManager(holder: projectHolder, deps: deps);

    homeHolder = HomeHolder();
    homeManager = HomeManager(deps: deps, holder: homeHolder);
  }

  Future<void> init() async {
    await projectManager.getDevices();
  }
}

final di = DI();
