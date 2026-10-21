import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/crash_report.dart';
import 'crash_repository.dart';

/// Collects unexpected errors (Flutter, uncaught async, failed providers) and
/// sends each kind once per session. Never throws: reporting must not crash.
class ErrorReporter {
  ErrorReporter(this._repository);

  final CrashRepository _repository;
  final _sent = <String>{};

  void record(Object error, StackTrace? stack, {String? context}) {
    if (!CrashReportPolicy.shouldReport(error)) return;
    if (_sent.length >= CrashReportPolicy.maxPerSession) return;
    final report = CrashReportPolicy.build(error, stack, context: context);
    if (!_sent.add(report.sessionKey)) return;
    if (!_repository.canReport) return;
    unawaited(
      _repository.send(report).catchError((Object e) {
        debugPrint('Crash report not sent: $e');
      }),
    );
  }

  /// Hooks the Flutter and platform error handlers.
  void install() {
    final previous = FlutterError.onError;
    FlutterError.onError = (details) {
      previous?.call(details);
      record(
        details.exception,
        details.stack,
        context: details.context?.toDescription() ?? details.library,
      );
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('Uncaught: $error\n$stack');
      record(error, stack, context: 'uncaught');
      return true;
    };
  }
}

/// Reports providers that fail (their error screens are otherwise silent).
final class ErrorReportingObserver extends ProviderObserver {
  ErrorReportingObserver(this._reporter);

  final ErrorReporter _reporter;

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    final provider = context.provider;
    _reporter.record(
      error,
      stackTrace,
      context: 'provider ${provider.name ?? provider.runtimeType}',
    );
  }
}
