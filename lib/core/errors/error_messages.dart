import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../l10n/l10n.dart';

/// Extracts a stable error code from Supabase errors. SQL functions raise
/// snake_case codes (e.g. `squad_full`) as the exception message.
String? errorCode(Object? error) => switch (error) {
  PostgrestException(code: '23505') => 'unique_violation',
  PostgrestException(code: '23514') => 'check_violation',
  PostgrestException(:final message) => message,
  AuthException(:final code, :final statusCode)
      when code == 'otp_expired' || statusCode == '403' =>
    'invalid_otp',
  AuthException(:final code, :final statusCode)
      when code == 'over_email_send_rate_limit' || statusCode == '429' =>
    'otp_rate_limit',
  SocketException() || TimeoutException() => 'network',
  AuthRetryableFetchException() => 'network',
  _ => null,
};

String errorMessage(AppLocalizations l10n, Object? error) =>
    switch (errorCode(error)) {
      'network' => l10n.errorNetwork,
      'invalid_otp' => l10n.errorInvalidOtp,
      'otp_rate_limit' => l10n.errorOtpRateLimit,
      'unique_violation' => l10n.errorUsernameTaken,
      'check_violation' => l10n.errorUsernameInvalid,
      'squad_full' => l10n.errorSquadFull,
      'invalid_invite_code' => l10n.errorInvalidInviteCode,
      'already_in_squad' => l10n.errorAlreadyInSquad,
      'relapse_in_future' => l10n.errorRelapseInFuture,
      'relapse_before_streak' => l10n.errorRelapseBeforeStreak,
      'quit_date_in_future' => l10n.errorQuitDateInFuture,
      'addiction_archived' => l10n.errorAddictionArchived,
      'too_many_addictions' => l10n.errorTooManyAddictions,
      _ => l10n.errorGeneric,
    };
