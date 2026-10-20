/// Mirrors the SQL constraints on squads (invite_code, size limit).
abstract final class SquadRules {
  static const maxMembers = 10;
  static final _code = RegExp(r'^[A-Z0-9]{6}$');

  static String normalizeInviteCode(String input) =>
      input.replaceAll(RegExp(r'\s'), '').toUpperCase();

  static bool isValidInviteCode(String input) =>
      _code.hasMatch(normalizeInviteCode(input));
}
