// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

typedef ManagerDeps = ({Logger logger, GlobalKey<NavigatorState> navigatorKey});
typedef MobileManagerDeps = ({Logger logger, GlobalKey<ScaffoldMessengerState> scaffoldKey});