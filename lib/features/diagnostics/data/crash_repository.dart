import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/crash_report.dart';

/// Sends crash reports to Supabase (private.client_errors through the
/// report_error RPC). Only for a signed-in player.
class CrashRepository {
  CrashRepository(this._client, {required this.build});

  final SupabaseClient _client;
  final int build;

  bool get canReport => build > 0 && _client.auth.currentUser != null;

  Future<void> send(CrashReport report) => _client.rpc<void>(
    'report_error',
    params: {
      'p_message': report.message,
      'p_stack': report.stack,
      'p_context': report.context,
      'p_build': build,
      'p_platform': '${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
    },
  );
}
