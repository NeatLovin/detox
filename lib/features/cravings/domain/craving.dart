/// Must match the CHECK constraint on `cravings.trigger`.
enum CravingTrigger {
  stress('stress', '😤'),
  boredom('boredom', '🥱'),
  party('party', '🎉'),
  afterMeal('after_meal', '🍽️'),
  morning('morning', '🌅'),
  screen('screen', '📱'),
  social('social', '👥'),
  tired('tired', '😴'),
  other('other', '❔');

  const CravingTrigger(this.dbValue, this.emoji);

  final String dbValue;
  final String emoji;

  static CravingTrigger fromDb(String? value) => CravingTrigger.values
      .firstWhere((t) => t.dbValue == value, orElse: () => CravingTrigger.other);
}

class Craving {
  const Craving({
    required this.id,
    required this.addictionId,
    required this.occurredAt,
    required this.intensity,
    required this.trigger,
    this.note,
    required this.resisted,
    required this.viaSos,
    required this.xpAwarded,
  });

  factory Craving.fromJson(Map<String, dynamic> json) => Craving(
    id: json['id'] as String,
    addictionId: json['addiction_id'] as String,
    occurredAt: DateTime.parse(json['occurred_at'] as String),
    intensity: (json['intensity'] as num).toInt(),
    trigger: CravingTrigger.fromDb(json['trigger'] as String?),
    note: json['note'] as String?,
    resisted: json['resisted'] as bool? ?? false,
    viaSos: json['via_sos'] as bool? ?? false,
    xpAwarded: (json['xp_awarded'] as num?)?.toInt() ?? 0,
  );

  final String id;
  final String addictionId;
  final DateTime occurredAt;
  final int intensity;
  final CravingTrigger trigger;
  final String? note;
  final bool resisted;
  final bool viaSos;
  final int xpAwarded;
}

class CravingInput {
  const CravingInput({
    required this.addictionId,
    required this.intensity,
    required this.trigger,
    required this.resisted,
    this.note,
  });

  final String addictionId;
  final int intensity;
  final CravingTrigger trigger;
  final bool resisted;
  final String? note;
}

/// Simple stats over recent cravings, shown above the journal.
class CravingStats {
  const CravingStats({
    required this.total,
    required this.resisted,
    this.topTrigger,
  });

  factory CravingStats.of(Iterable<Craving> cravings) {
    final list = cravings.toList();
    final counts = <CravingTrigger, int>{};
    for (final c in list) {
      counts[c.trigger] = (counts[c.trigger] ?? 0) + 1;
    }
    CravingTrigger? top;
    var best = 0;
    for (final entry in counts.entries) {
      if (entry.key != CravingTrigger.other && entry.value > best) {
        top = entry.key;
        best = entry.value;
      }
    }
    return CravingStats(
      total: list.length,
      resisted: list.where((c) => c.resisted).length,
      topTrigger: top,
    );
  }

  final int total;
  final int resisted;
  final CravingTrigger? topTrigger;

  /// Percentage of cravings resisted (0 when there are none).
  int get resistedPercent => total == 0 ? 0 : (resisted * 100 / total).round();
}
