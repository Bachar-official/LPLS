import 'package:flutter/material.dart';
import 'package:lpls/domain/entiy/manager_deps.dart';
import 'package:lpls/feature/effect_editor/effect_holder.dart';
import 'package:lpls/feature/effect_editor/effect_manager.dart';
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

  late final EffectHolder effectHolder;
  late final EffectManager effectManager;

  final Logger logger = Logger();
  final GlobalKey<ScaffoldMessengerState> scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  late final ManagerDeps deps;

  DI() {
    deps = (logger: logger, scaffoldKey: scaffoldKey);
    projectHolder = ProjectHolder();
    projectManager = ProjectManager(holder: projectHolder, deps: deps);

    homeHolder = HomeHolder();
    homeManager = HomeManager(deps: deps, holder: homeHolder);

    effectHolder = EffectHolder();
    effectManager = EffectManager(deps: deps, holder: effectHolder);
  }

  Future<void> init() async {
    await projectManager.getDevices();
  }
}

final di = DI();
