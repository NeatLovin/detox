import 'dart:io';

import 'package:detox/core/errors/error_messages.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('isNetworkError', () {
    test('true for real connectivity failures', () {
      expect(isNetworkError(const SocketException('offline')), isTrue);
      expect(isNetworkError(AuthRetryableFetchException(message: 'Failed host lookup')), isTrue);
    });

    test('false for a 5xx answer from the auth server', () {
      final error = AuthRetryableFetchException(
        message: 'Error sending magic link email',
        statusCode: '500',
      );
      expect(isNetworkError(error), isFalse);
      expect(errorCode(error), isNull);
    });
  });

  group('errorDetail', () {
    test('shows status and server message', () {
      final error = AuthRetryableFetchException(
        message: 'Error sending magic link email',
        statusCode: '500',
      );
      expect(errorDetail(error), '500 : Error sending magic link email');
    });

    test('extracts msg from the JSON body of a 5xx answer', () {
      final error = AuthRetryableFetchException(
        message: '{"code":500,"error_code":"unexpected_failure","msg":"Error sending confirmation email"}',
        statusCode: '500',
      );
      expect(errorDetail(error), '500 : Error sending confirmation email');
    });

    test('truncates long messages', () {
      final detail = errorDetail(AuthException('x' * 500, statusCode: '500'));
      expect(detail!.length, lessThan(200));
    });
  });

  test('known codes still map to their dedicated message', () {
    expect(errorCode(const AuthException('expired', statusCode: '403')), 'invalid_otp');
    expect(errorCode(const AuthException('slow down', statusCode: '429')), 'otp_rate_limit');
  });
}
