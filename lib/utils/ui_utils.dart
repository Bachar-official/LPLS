import 'package:flutter/material.dart';
import 'package:lpls/domain/entiy/manager_deps.dart';

void debug(ManagerDeps deps, String message) => deps.logger.d(message);
void warning(ManagerDeps deps, String message, {bool showScaffold = false, String scaffoldMessage = ''}) {
  deps.logger.w(message);
  if (showScaffold) {
    deps.scaffoldKey.currentState?.showSnackBar(
      SnackBar(content: Text(scaffoldMessage), backgroundColor: Colors.yellow),
    );
  }
}
void success(ManagerDeps deps, String message, {bool showScaffold = false, String scaffoldMessage = ''}) {
  deps.logger.i(message);
  if (showScaffold) {
    deps.scaffoldKey.currentState?.showSnackBar(
      SnackBar(content: Text(scaffoldMessage), backgroundColor: Colors.green),
    );
  }
}
void catchException(ManagerDeps deps, Object e, {String? description, StackTrace? stackTrace}) {
  deps.logger.e(e, stackTrace: stackTrace);
  deps.scaffoldKey.currentState!.showSnackBar(
    SnackBar(content: Text('${description ?? ''}$e'), backgroundColor: Colors.red),
  );
}
