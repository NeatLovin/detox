/// Pure rules of the settings screen, tested in test/features/settings_test.dart.
abstract final class AccountDeletion {
  /// Word the player types to confirm, so the deletion is never a misclick.
  static const confirmationWord = 'SUPPRIMER';

  static bool isConfirmed(String input) =>
      input.trim().toUpperCase() == confirmationWord;
}

abstract final class TwintDonation {
  /// Number as TWINT expects it when pasted: digits only, with a leading +
  /// kept for international numbers.
  static String normalize(String phone) {
    final trimmed = phone.trim();
    final digits = trimmed.replaceAll(RegExp(r'\D'), '');
    return trimmed.startsWith('+') ? '+$digits' : digits;
  }

  /// Readable Swiss format: "079 123 45 67" or "+41 79 123 45 67".
  /// Any other shape is returned as typed.
  static String format(String phone) {
    final n = normalize(phone);
    final local = RegExp(r'^0(\d{2})(\d{3})(\d{2})(\d{2})$').firstMatch(n);
    if (local != null) {
      return '0${local[1]} ${local[2]} ${local[3]} ${local[4]}';
    }
    final swiss = RegExp(r'^\+41(\d{2})(\d{3})(\d{2})(\d{2})$').firstMatch(n);
    if (swiss != null) {
      return '+41 ${swiss[1]} ${swiss[2]} ${swiss[3]} ${swiss[4]}';
    }
    return phone.trim();
  }
}
