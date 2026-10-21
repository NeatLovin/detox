import '../../addictions/domain/addiction.dart';

/// "body": physiological milestones from a cited source.
/// "progress": habit milestones only, no medical claim.
enum TimelineKind { body, progress }

class HealthMilestone {
  const HealthMilestone({
    required this.after,
    required this.emoji,
    required this.title,
    required this.body,
  });

  factory HealthMilestone.fromJson(Map<String, dynamic> json) => HealthMilestone(
    after: Duration(minutes: (json['after_minutes'] as num).toInt()),
    emoji: json['emoji'] as String,
    title: json['title'] as String,
    body: json['body'] as String,
  );

  /// Time clean after which this milestone is reached.
  final Duration after;
  final String emoji;
  final String title;
  final String body;
}

class HealthTimeline {
  const HealthTimeline({
    required this.kind,
    required this.milestones,
    this.source,
    this.sourceUrl,
    this.warning,
  });

  factory HealthTimeline.fromJson(Map<String, dynamic> json) => HealthTimeline(
    kind: json['kind'] == 'body' ? TimelineKind.body : TimelineKind.progress,
    milestones: [
      for (final raw in json['milestones'] as List)
        HealthMilestone.fromJson(Map<String, dynamic>.from(raw as Map)),
    ]..sort((a, b) => a.after.compareTo(b.after)),
    source: json['source'] as String?,
    sourceUrl: json['source_url'] as String?,
    warning: json['warning'] as String?,
  );

  final TimelineKind kind;

  /// Sorted by [HealthMilestone.after].
  final List<HealthMilestone> milestones;
  final String? source;
  final String? sourceUrl;

  /// Safety note shown above the timeline (e.g. alcohol withdrawal).
  final String? warning;

  List<HealthMilestone> reached(Duration clean) =>
      milestones.where((m) => m.after <= clean).toList();

  HealthMilestone? latest(Duration clean) {
    final done = reached(clean);
    return done.isEmpty ? null : done.last;
  }

  HealthMilestone? next(Duration clean) {
    for (final m in milestones) {
      if (m.after > clean) return m;
    }
    return null;
  }

  /// 0..1 progress from the previous milestone (or the start) to the next one.
  double progressToNext(Duration clean) {
    final upcoming = next(clean);
    if (upcoming == null) return 1;
    final from = latest(clean)?.after ?? Duration.zero;
    final span = (upcoming.after - from).inSeconds;
    if (span <= 0) return 1;
    return ((clean - from).inSeconds / span).clamp(0.0, 1.0);
  }
}

/// Every addiction type's timeline, parsed from assets/content/health_timeline_fr.json.
class HealthTimelines {
  const HealthTimelines({required this.disclaimer, required this.byType});

  factory HealthTimelines.fromJson(Map<String, dynamic> json) => HealthTimelines(
    disclaimer: json['disclaimer'] as String? ?? '',
    byType: {
      for (final entry in (json['types'] as Map).entries)
        AddictionType.fromDb(entry.key as String):
            HealthTimeline.fromJson(Map<String, dynamic>.from(entry.value as Map)),
    },
  );

  final String disclaimer;
  final Map<AddictionType, HealthTimeline> byType;

  HealthTimeline? of(AddictionType type) => byType[type] ?? byType[AddictionType.custom];
}
