import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../l10n/l10n.dart';

/// True when the request never got an HTTP answer (offline, DNS, timeout).
///
/// The auth SDK throws [AuthRetryableFetchException] both for network
/// failures (no status code) and for 5xx server answers (with a status code):
/// only the former is a connectivity problem.
bool isNetworkError(Object? error) => switch (error) {
  SocketException() || TimeoutException() => true,
  AuthRetryableFetchException(:final statusCode) =>
    statusCode == null || statusCode.isEmpty || statusCode == '0',
  _ => false,
};

/// Extracts a stable error code from Supabase errors. SQL functions raise
/// snake_case codes (e.g. `too_many_quests`) as the exception message.
String? errorCode(Object? error) {
  if (isNetworkError(error)) return 'network';
  return switch (error) {
    PostgrestException(code: '23505') => 'unique_violation',
    PostgrestException(code: '23514') => 'check_violation',
    PostgrestException(:final message) => message,
    AuthException(:final code, :final statusCode)
        when code == 'otp_expired' || statusCode == '403' =>
      'invalid_otp',
    AuthException(:final code, :final statusCode)
        when code == 'over_email_send_rate_limit' || statusCode == '429' =>
      'otp_rate_limit',
    _ => null,
  };
}

/// Technical detail appended to the generic message, so an unexpected server
/// answer (e.g. "500: Error sending magic link email") is visible on screen.
String? errorDetail(Object? error) {
  final (status, message) = switch (error) {
    AuthException(:final statusCode, :final message) => (statusCode, message),
    PostgrestException(:final code, :final message) => (code, message),
    _ => (null, error?.toString()),
  };
  if (message == null || message.trim().isEmpty) return status;
  final text = _serverMessage(message.trim());
  final short = text.length > 160 ? '${text.substring(0, 160)}…' : text;
  return status == null || status.isEmpty ? short : '$status : $short';
}

String errorMessage(AppLocalizations l10n, Object? error) =>
    switch (errorCode(error)) {
      'network' => l10n.errorNetwork,
      'invalid_otp' => l10n.errorInvalidOtp,
      'otp_rate_limit' => l10n.errorOtpRateLimit,
      'unique_violation' => l10n.errorUsernameTaken,
      'check_violation' => l10n.errorUsernameInvalid,
      'profile_private' => l10n.errorProfilePrivate,
      'player_not_found' => l10n.errorPlayerNotFound,
      'relapse_in_future' => l10n.errorRelapseInFuture,
      'relapse_before_streak' => l10n.errorRelapseBeforeStreak,
      'quit_date_in_future' => l10n.errorQuitDateInFuture,
      'addiction_archived' => l10n.errorAddictionArchived,
      'too_many_addictions' => l10n.errorTooManyAddictions,
      'too_many_quests' => l10n.errorTooManyQuests,
      'quest_day_out_of_range' => l10n.errorQuestDayOutOfRange,
      'quest_archived' => l10n.errorQuestArchived,
      'craving_in_future' => l10n.errorCravingInFuture,
      'craving_too_old' => l10n.errorCravingTooOld,
      'sos_not_found' => l10n.errorSosNotFound,
      'sos_own_alert' => l10n.errorSosOwnAlert,
      'sos_expired' => l10n.errorSosExpired,
      'sos_already_resolved' => l10n.errorSosAlreadyResolved,
      'too_many_motivations' => l10n.errorTooManyMotivations,
      _ => _withDetail(l10n.errorGeneric, errorDetail(error)),
    };

/// 5xx auth answers carry the raw JSON body, e.g.
/// `{"code":500,"error_code":"unexpected_failure","msg":"Error sending magic link email"}`.
String _serverMessage(String raw) {
  if (!raw.startsWith('{')) return raw;
  try {
    final data = jsonDecode(raw);
    if (data is Map) {
      final msg = data['msg'] ?? data['message'] ?? data['error_description'] ?? data['error'];
      if (msg is String && msg.isNotEmpty) return msg;
    }
  } on FormatException {
    // Not JSON after all: show it as is.
  }
  return raw;
}

String _withDetail(String message, String? detail) =>
    detail == null ? message : '$message\n($detail)';
