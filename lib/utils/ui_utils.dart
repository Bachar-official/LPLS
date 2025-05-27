import 'package:fluent_ui/fluent_ui.dart';
import 'package:lpls/domain/entiy/manager_deps.dart';

void debug(ManagerDeps deps, String message) => deps.logger.d(message);
void warning(
  ManagerDeps deps,
  String message, {
  bool showScaffold = false,
  String scaffoldMessage = '',
}) async {
  deps.logger.w(message);
  if (showScaffold) {
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
  bool showScaffold = false,
  String scaffoldMessage = '',
}) async {
  deps.logger.i(message);
  if (showScaffold) {
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
