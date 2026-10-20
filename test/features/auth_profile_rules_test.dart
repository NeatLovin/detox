import 'package:detox/core/utils/numbers.dart';
import 'package:detox/features/auth/domain/auth_rules.dart';
import 'package:detox/features/onboarding/domain/profile_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthRules', () {
    test('email validation', () {
      expect(AuthRules.isValidEmail('max@pote.ch'), isTrue);
      expect(AuthRules.isValidEmail('  max@pote.ch '), isTrue);
      expect(AuthRules.isValidEmail('max@pote'), isFalse);
      expect(AuthRules.isValidEmail('max pote@x.ch'), isFalse);
      expect(AuthRules.isValidEmail(''), isFalse);
    });

    test('OTP is exactly 6 digits', () {
      expect(AuthRules.isValidOtp('123456'), isTrue);
      expect(AuthRules.isValidOtp('12345'), isFalse);
      expect(AuthRules.isValidOtp('1234567'), isFalse);
      expect(AuthRules.isValidOtp('12a456'), isFalse);
    });

    test('resend cooldown is 60 s', () {
      final sent = DateTime(2026, 1, 1, 12);
      expect(AuthRules.resendSecondsLeft(null, sent), 0);
      expect(AuthRules.resendSecondsLeft(sent, sent), 60);
      expect(
        AuthRules.resendSecondsLeft(
          sent,
          sent.add(const Duration(seconds: 59, milliseconds: 500)),
        ),
        1,
      );
      expect(
        AuthRules.resendSecondsLeft(
          sent,
          sent.add(const Duration(seconds: 60)),
        ),
        0,
      );
      expect(
        AuthRules.resendSecondsLeft(sent, sent.add(const Duration(hours: 1))),
        0,
      );
    });
  });

  group('ProfileRules.isValidUsername', () {
    test('accepts 3 to 20 allowed characters', () {
      expect(ProfileRules.isValidUsername('Max'), isTrue);
      expect(ProfileRules.isValidUsername('max_le.boss-99'), isTrue);
      expect(ProfileRules.isValidUsername('a' * 20), isTrue);
    });

    test('rejects too short, too long and special characters', () {
      expect(ProfileRules.isValidUsername('ab'), isFalse);
      expect(ProfileRules.isValidUsername('a' * 21), isFalse);
      expect(ProfileRules.isValidUsername('max boss'), isFalse);
      expect(ProfileRules.isValidUsername('Zoé'), isFalse);
    });
  });

  group('parseDecimal', () {
    test('accepts dot and comma', () {
      expect(parseDecimal('0.45'), 0.45);
      expect(parseDecimal('0,45'), 0.45);
      expect(parseDecimal(' 10 '), 10);
    });

    test('rejects empty, negative and garbage', () {
      expect(parseDecimal(''), isNull);
      expect(parseDecimal('-1'), isNull);
      expect(parseDecimal('abc'), isNull);
    });

    test('formatDecimalInput round-trips', () {
      expect(formatDecimalInput(10), '10');
      expect(formatDecimalInput(0.45), '0.45');
      expect(formatDecimalInput(0.3), '0.3');
    });
  });
}
