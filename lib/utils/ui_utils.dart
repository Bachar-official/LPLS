import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' hide Colors, IconButton;
import 'package:lpls/domain/entiy/manager_deps.dart';

void debug(ManagerDeps deps, String message) => deps.logger.d(message);
void warning(
  ManagerDeps deps,
  String message, {
  String scaffoldMessage = '',
}) async {
  deps.logger.w(message);
  if (scaffoldMessage.isNotEmpty) {
    await displayInfoBar(
      deps.navigatorKey.currentContext!,
      builder:
          (context, close) => InfoBar(
            title: Text(scaffoldMessage),
            action: IconButton(
              icon: const Icon(FluentIcons.clear),
              onPressed: close,
            ),
            severity: InfoBarSeverity.warning,
          ),
    );
  }
}

void success(
  ManagerDeps deps,
  String message, {
  String scaffoldMessage = '',
}) async {
  deps.logger.i(message);
  if (scaffoldMessage.isNotEmpty) {
    await displayInfoBar(
      deps.navigatorKey.currentContext!,
      builder:
          (context, close) => InfoBar(
            title: Text(scaffoldMessage),
            action: IconButton(
              icon: const Icon(FluentIcons.clear),
              onPressed: close,
            ),
            severity: InfoBarSeverity.success,
          ),
    );
  }
}

void catchException(
  ManagerDeps deps,
  Object e, {
  String? description,
  StackTrace? stackTrace,
}) async {
  deps.logger.e(e, stackTrace: stackTrace);
  await displayInfoBar(
    deps.navigatorKey.currentContext!,
    builder:
        (context, close) => InfoBar(
          title: Text(e.toString()),
          action: IconButton(
            icon: const Icon(FluentIcons.clear),
            onPressed: close,
          ),
          severity: InfoBarSeverity.error,
        ),
  );
}

void mobileDebug(MobileManagerDeps deps, String message) =>
    deps.logger.d(message);
void mobileWarning(
  MobileManagerDeps deps,
  String message, {
  String scaffoldMessage = '',
}) {
  deps.logger.w(message);
  if (scaffoldMessage.isNotEmpty &&
      deps.scaffoldKey.currentState != null) {
    deps.scaffoldKey.currentState?.showSnackBar(
    SnackBar(backgroundColor: Colors.orange, content: Text(scaffoldMessage)));
  }
}

void mobileSuccess(
  MobileManagerDeps deps,
  String message, {
  String scaffoldMessage = '',
}) {
  deps.logger.i(message);
  if (scaffoldMessage.isNotEmpty &&
      deps.scaffoldKey.currentState != null) {
      deps.scaffoldKey.currentState?.showSnackBar(
    SnackBar(backgroundColor: Colors.green, content: Text(scaffoldMessage)));
  }
}

void mobileCatchException(
  MobileManagerDeps deps,
  Object e, {
  String? description,
  StackTrace? stackTrace,
}) {
  deps.logger.e(e, stackTrace: stackTrace);
  if (deps.scaffoldKey.currentState != null) {
    deps.scaffoldKey.currentState?.showSnackBar(
    SnackBar(backgroundColor: Colors.red, content: Text(e.toString())),
  );
  }  
}
