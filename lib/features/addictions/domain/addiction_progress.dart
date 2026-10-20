import 'dart:math' as math;

import '../../gamification/domain/milestones.dart';

/// Pure computations behind the addiction card. A "day" is 24 h of real
/// elapsed time (same as the SQL job), so DST changes never skip or double a day.
abstract final class AddictionProgress {
  static const secondsPerDay = 86400;

  /// Tolerance for client/server clock drift (same as the SQL triggers).
  static const clockTolerance = Duration(minutes: 1);

  /// Time clean since [streakStartedAt]. Never negative.
  static Duration cleanDuration(DateTime streakStartedAt, DateTime now) {
    final diff = now.toUtc().difference(streakStartedAt.toUtc());
    return diff.isNegative ? Duration.zero : diff;
  }

  /// Full clean days, as awarded by the server (floor of 24 h periods).
  static int fullCleanDays(Duration clean) => clean.inSeconds ~/ secondsPerDay;

  static double _days(Duration clean) => clean.inSeconds / secondsPerDay;

  /// CHF saved during the current streak, prorated to the second.
  static double moneySaved({
    required Duration clean,
    required double unitCost,
    required double baselinePerDay,
  }) => _days(clean) * baselinePerDay * unitCost;

  /// Units not consumed during the current streak.
  static double unitsAvoided({
    required Duration clean,
    required double baselinePerDay,
  }) => _days(clean) * baselinePerDay;

  /// Personal record: the stored best streak, or the current one if longer.
  static Duration bestStreak({
    required int bestStreakSeconds,
    required Duration current,
  }) {
    final stored = Duration(seconds: bestStreakSeconds);
    return current > stored ? current : stored;
  }

  /// Next milestone to reach and progress towards it. Null once every
  /// milestone of the streak has been reached.
  static MilestoneProgress? nextMilestone(Duration clean) {
    final days = fullCleanDays(clean);
    var previousDays = 0;
    for (final milestone in Milestones.all) {
      if (milestone.days > days) {
        final span = (milestone.days - previousDays) * secondsPerDay;
        final done = clean.inSeconds - previousDays * secondsPerDay;
        return MilestoneProgress(
          milestone: milestone,
          ratio: (done / span).clamp(0.0, 1.0),
          remaining: Duration(seconds: milestone.days * secondsPerDay) - clean,
        );
      }
      previousDays = milestone.days;
    }
    return null;
  }

  static DurationParts split(Duration duration) {
    final d = duration.isNegative ? Duration.zero : duration;
    return DurationParts(
      days: d.inDays,
      hours: d.inHours % 24,
      minutes: d.inMinutes % 60,
      seconds: d.inSeconds % 60,
    );
  }

  /// Validates a relapse date. Mirrors the SQL checks in on_relapse_before_insert.
  static RelapseTimeCheck checkRelapseTime({
    required DateTime occurredAt,
    required DateTime streakStartedAt,
    required DateTime now,
  }) {
    if (occurredAt.toUtc().isAfter(now.toUtc().add(clockTolerance))) {
      return RelapseTimeCheck.inFuture;
    }
    if (occurredAt.toUtc().isBefore(streakStartedAt.toUtc())) {
      return RelapseTimeCheck.beforeStreak;
    }
    return RelapseTimeCheck.ok;
  }

  /// A quit date may be in the past, never in the future.
  static bool isValidQuitDate(DateTime quitStartedAt, DateTime now) =>
      !quitStartedAt.toUtc().isAfter(now.toUtc().add(clockTolerance));

  /// Earliest date offered by the relapse picker.
  static DateTime earliestRelapse(DateTime streakStartedAt, DateTime now) {
    final start = streakStartedAt.toLocal();
    return start.isAfter(now) ? now : start;
  }

  static int roundedUnits(double units) => math.max(0, units.floor());
}

enum RelapseTimeCheck { ok, inFuture, beforeStreak }

class MilestoneProgress {
  const MilestoneProgress({
    required this.milestone,
    required this.ratio,
    required this.remaining,
  });

  final Milestone milestone;

  /// 0.0 → 1.0 between the previous milestone (or the streak start) and this one.
  final double ratio;
  final Duration remaining;
}

class DurationParts {
  const DurationParts({
    required this.days,
    required this.hours,
    required this.minutes,
    required this.seconds,
  });

  final int days;
  final int hours;
  final int minutes;
  final int seconds;

  @override
  bool operator ==(Object other) =>
      other is DurationParts &&
      other.days == days &&
      other.hours == hours &&
      other.minutes == minutes &&
      other.seconds == seconds;

  @override
  int get hashCode => Object.hash(days, hours, minutes, seconds);

  @override
  String toString() => '${days}j ${hours}h ${minutes}m ${seconds}s';
}
