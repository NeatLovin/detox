/// Badge keys. Must match the CHECK constraint on `badges.key`
/// (test/sql_parity_test.dart). Badges are unlocked server side only.
enum BadgeKey {
  firstPledge('first_pledge', '🤝'),
  pledgeStreak7('pledge_streak_7', '📅'),
  firstResist('first_resist', '🛡️'),
  resist10('resist_10', '🧱'),
  sosFirst('sos_first', '🆘'),
  helper('helper', '🫂'),
  streak7('streak_7', '🔥'),
  streak30('streak_30', '🌙'),
  streak90('streak_90', '👑'),
  comeback('comeback', '🦅'),
  questStreak7('quest_streak_7', '🎯'),
  level5('level_5', '⭐'),
  level10('level_10', '🌟');

  const BadgeKey(this.dbValue, this.emoji);

  final String dbValue;
  final String emoji;

  static BadgeKey? fromDb(String? value) {
    for (final key in values) {
      if (key.dbValue == value) return key;
    }
    return null;
  }
}

class UnlockedBadge {
  const UnlockedBadge({required this.key, required this.unlockedAt});

  final BadgeKey key;
  final DateTime unlockedAt;
}
