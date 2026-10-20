/// Pure validation and timing rules for the OTP sign-in flow.
abstract final class AuthRules {
  static const otpLength = 6;
  static const resendCooldown = Duration(seconds: 60);

  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _otp = RegExp(r'^\d{6}$');

  static bool isValidEmail(String value) => _email.hasMatch(value.trim());

  static bool isValidOtp(String value) => _otp.hasMatch(value.trim());

  /// Seconds left before a new code can be requested (0 = allowed now).
  static int resendSecondsLeft(DateTime? lastSentAt, DateTime now) {
    if (lastSentAt == null) return 0;
    final left = resendCooldown - now.difference(lastSentAt);
    if (left <= Duration.zero) return 0;
    return (left.inMilliseconds / 1000).ceil();
  }
}
