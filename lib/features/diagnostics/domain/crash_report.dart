import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/error_messages.dart';

/// One unexpected error, ready to be sent.
class CrashReport {
  const CrashReport({required this.message, this.stack, this.context});

  final String message;
  final String? stack;
  final String? context;

  /// Same error at the same place: sent once per app session.
  String get sessionKey => '$message|${stack?.split('\n').take(3).join('|')}';
}

/// Pure rules of crash reporting, tested in test/features/diagnostics_test.dart.
abstract final class CrashReportPolicy {
  /// Reports sent per app session at most.
  static const maxPerSession = 20;

  /// Stack lines kept (the top of the stack is where the bug is).
  static const maxStackLines = 25;

  static const _networkHints = [
    'SocketException',
    'Failed host lookup',
    'Connection closed',
    'Connection reset',
    'Connection refused',
    'Network is unreachable',
    'HandshakeException',
    'TimeoutException',
    'RealtimeSubscribeException',
  ];

  /// Offline moments and expected business answers (an SQL rule saying no)
  /// are not bugs.
  static bool shouldReport(Object error) {
    if (isNetworkError(error)) return false;
    if (error is PostgrestException && error.code == 'P0001') return false;
    if (error is AuthException) return false;
    final text = error.toString();
    return !_networkHints.any(text.contains);
  }

  static CrashReport build(Object error, StackTrace? stack, {String? context}) =>
      CrashReport(
        message: error.toString(),
        stack: trimStack(stack),
        context: context,
      );

  static String? trimStack(StackTrace? stack) {
    if (stack == null) return null;
    final lines = stack
        .toString()
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .take(maxStackLines)
        .toList();
    return lines.isEmpty ? null : lines.join('\n');
  }
}
