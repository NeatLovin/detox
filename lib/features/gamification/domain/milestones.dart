/// Clean-day milestones and their one-shot XP bonus (once per streak).
/// Duplicated in SQL (private.milestones) — test/sql_parity_test.dart.
class Milestone {
  const Milestone(this.days, this.bonusXp);

  final int days;
  final int bonusXp;

  @override
  bool operator ==(Object other) =>
      other is Milestone && other.days == days && other.bonusXp == bonusXp;

  @override
  int get hashCode => Object.hash(days, bonusXp);

  @override
  String toString() => 'Milestone($days d, +$bonusXp XP)';
}

abstract final class Milestones {
  static const all = <Milestone>[
    Milestone(1, 20),
    Milestone(3, 50),
    Milestone(7, 100),
    Milestone(14, 150),
    Milestone(30, 300),
    Milestone(60, 400),
    Milestone(90, 600),
    Milestone(180, 1000),
    Milestone(365, 2000),
  ];

  /// HP gained for each full clean day.
  static const hpPerCleanDay = 5;

  /// HP lost on a relapse. XP is never lost.
  static const hpPerRelapse = 25;
}
