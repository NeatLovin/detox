/// Coarse relative time for the feed.
enum TimeAgoUnit { now, minutes, hours, days }

class TimeAgo {
  const TimeAgo(this.unit, this.value);

  factory TimeAgo.between(DateTime past, DateTime now) {
    final diff = now.toUtc().difference(past.toUtc());
    if (diff.inMinutes < 1) return const TimeAgo(TimeAgoUnit.now, 0);
    if (diff.inHours < 1) return TimeAgo(TimeAgoUnit.minutes, diff.inMinutes);
    if (diff.inDays < 1) return TimeAgo(TimeAgoUnit.hours, diff.inHours);
    return TimeAgo(TimeAgoUnit.days, diff.inDays);
  }

  final TimeAgoUnit unit;
  final int value;

  @override
  bool operator ==(Object other) =>
      other is TimeAgo && other.unit == unit && other.value == value;

  @override
  int get hashCode => Object.hash(unit, value);

  @override
  String toString() => 'TimeAgo($unit, $value)';
}
