/// Emojis a squad mate can send to an SOS. Must match the CHECK constraint
/// on `sos_supports.emoji`.
const sosSupportEmojis = <String>['💪', '🔥', '🫂', '🧠', '🏆'];

/// How long the SOS countdown lasts: most cravings fade within a few minutes.
const sosDuration = Duration(minutes: 5);

class SosAlert {
  const SosAlert({
    required this.id,
    required this.userId,
    this.squadId,
    this.addictionId,
    required this.addictionLabel,
    required this.createdAt,
    this.resolvedAt,
    this.outcome,
  });

  factory SosAlert.fromJson(Map<String, dynamic> json) => SosAlert(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    squadId: json['squad_id'] as String?,
    addictionId: json['addiction_id'] as String?,
    addictionLabel: json['addiction_label'] as String? ?? '',
    createdAt: DateTime.parse(json['created_at'] as String),
    resolvedAt: json['resolved_at'] == null
        ? null
        : DateTime.parse(json['resolved_at'] as String),
    outcome: json['outcome'] as String?,
  );

  final String id;
  final String userId;
  final String? squadId;
  final String? addictionId;
  final String addictionLabel;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? outcome;

  bool get isOpen => resolvedAt == null;

  /// Shown to the squad while open and recent enough to still matter.
  bool isActive(DateTime now) =>
      isOpen && now.difference(createdAt) < const Duration(hours: 2);
}

class SosSupport {
  const SosSupport({
    required this.alertId,
    required this.userId,
    required this.emoji,
    required this.createdAt,
  });

  factory SosSupport.fromJson(Map<String, dynamic> json) => SosSupport(
    alertId: json['alert_id'] as String,
    userId: json['user_id'] as String,
    emoji: json['emoji'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  final String alertId;
  final String userId;
  final String emoji;
  final DateTime createdAt;
}

enum BreathPhase { inhale, hold, exhale }

/// Paced breathing: inhale 4 s, hold 4 s, exhale 6 s (a long exhale calms).
abstract final class Breathing {
  static const inhale = Duration(seconds: 4);
  static const hold = Duration(seconds: 4);
  static const exhale = Duration(seconds: 6);
  static const cycle = Duration(seconds: 14);

  /// Phase and progress (0..1) within the phase, [elapsed] since the start.
  static (BreathPhase, double) at(Duration elapsed) {
    final ms = elapsed.inMilliseconds % cycle.inMilliseconds;
    if (ms < inhale.inMilliseconds) {
      return (BreathPhase.inhale, ms / inhale.inMilliseconds);
    }
    final afterInhale = ms - inhale.inMilliseconds;
    if (afterInhale < hold.inMilliseconds) {
      return (BreathPhase.hold, afterInhale / hold.inMilliseconds);
    }
    final afterHold = afterInhale - hold.inMilliseconds;
    return (BreathPhase.exhale, afterHold / exhale.inMilliseconds);
  }

  /// Circle scale for the animation: grows on inhale, stays, shrinks on exhale.
  static double scale(Duration elapsed) {
    final (phase, t) = at(elapsed);
    const min = 0.55;
    const max = 1.0;
    return switch (phase) {
      BreathPhase.inhale => min + (max - min) * t,
      BreathPhase.hold => max,
      BreathPhase.exhale => max - (max - min) * t,
    };
  }
}

/// `m:ss` of what is left of the countdown (never negative).
String formatCountdown(Duration left) {
  final clamped = left.isNegative ? Duration.zero : left;
  final minutes = clamped.inMinutes;
  final seconds = (clamped.inSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
