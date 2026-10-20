/// V1 rewards, granted server side by `private.try_reward` and capped per day.
/// Duplicated in SQL (private.reward_rules) — test/sql_parity_test.dart.
class RewardRule {
  const RewardRule({
    required this.key,
    required this.reason,
    required this.xp,
    required this.dailyCap,
  });

  final String key;
  final String reason;
  final int xp;
  final int dailyCap;

  @override
  bool operator ==(Object other) =>
      other is RewardRule &&
      other.key == key &&
      other.reason == reason &&
      other.xp == xp &&
      other.dailyCap == dailyCap;

  @override
  int get hashCode => Object.hash(key, reason, xp, dailyCap);

  @override
  String toString() => 'RewardRule($key, $reason, +$xp XP, $dailyCap/day)';
}

abstract final class Rewards {
  static const craving = RewardRule(
    key: 'craving',
    reason: 'craving',
    xp: 10,
    dailyCap: 3,
  );
  static const cravingSos = RewardRule(
    key: 'craving_sos',
    reason: 'craving',
    xp: 15,
    dailyCap: 3,
  );
  static const quest = RewardRule(
    key: 'quest',
    reason: 'quest',
    xp: 10,
    dailyCap: 6,
  );
  static const questsAllDone = RewardRule(
    key: 'quests_all_done',
    reason: 'quests_all_done',
    xp: 20,
    dailyCap: 1,
  );
  static const pledge = RewardRule(
    key: 'pledge',
    reason: 'pledge',
    xp: 5,
    dailyCap: 1,
  );
  static const sosSupport = RewardRule(
    key: 'sos_support',
    reason: 'sos_support',
    xp: 5,
    dailyCap: 5,
  );

  static const all = <RewardRule>[
    craving,
    cravingSos,
    quest,
    questsAllDone,
    pledge,
    sosSupport,
  ];

  /// The all-done bonus needs at least this many active quests.
  static const minQuestsForAllDoneBonus = 3;
}
