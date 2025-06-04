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
import 'package:lpls/feature/track_editor/track_holder.dart';
import 'package:lpls/feature/track_editor/track_manager.dart';
import 'package:minisound/engine_flutter.dart' as minisound;

class DI {
  late final ProjectHolder projectHolder;
  late final ProjectManager projectManager;

  late final HomeHolder homeHolder;
  late final HomeManager homeManager;

  late final EffectHolder effectHolder;
  late final EffectManager effectManager;

  late final TrackHolder trackHolder;
  late final TrackManager trackManager;

  final Logger logger = Logger();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  late final ManagerDeps deps;

  late final minisound.Engine audioEngine;

  DI() {
    audioEngine = minisound.Engine();
    deps = (logger: logger, navigatorKey: navigatorKey);

    homeHolder = HomeHolder();
    homeManager = HomeManager(deps: deps, holder: homeHolder);

    effectHolder = EffectHolder();
    effectManager = EffectManager(
      deps: deps,
      holder: effectHolder,
      homeManager: homeManager,
    );

    trackHolder = TrackHolder();
    trackManager = TrackManager(
      deps: deps,
      holder: trackHolder,
      homeManager: homeManager,
    );

    projectHolder = ProjectHolder(engine: audioEngine);
    projectManager = ProjectManager(
      holder: projectHolder,
      deps: deps,
      effectManager: effectManager,
      trackManager: trackManager,
      homeManager: homeManager,
    );
  }

  Future<void> init() async {
    await audioEngine.init();
    await audioEngine.start();
    await projectManager.getDevices();
  }
}

final di = DI();
