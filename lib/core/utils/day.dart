/// Calendar-day helpers. Server-side days are Europe/Zurich; the app uses the
/// device's local day, which is the same for a squad living in Switzerland.
DateTime dayOf(DateTime moment) {
  final local = moment.toLocal();
  return DateTime(local.year, local.month, local.day);
}

/// `yyyy-mm-dd`, the format of a Postgres `date`.
String dayKey(DateTime day) {
  final d = dayOf(day);
  final month = d.month.toString().padLeft(2, '0');
  final dayOfMonth = d.day.toString().padLeft(2, '0');
  return '${d.year}-$month-$dayOfMonth';
}

/// Parses a Postgres `date` (`yyyy-mm-dd`) as a local calendar day.
DateTime parseDay(String value) {
  final parts = value.split('-').map(int.parse).toList();
  return DateTime(parts[0], parts[1], parts[2]);
}

/// Number of consecutive days ending today (or yesterday, if today is not
/// done yet) found in [doneDays]. A streak still counts while today is open.
int consecutiveDays(Iterable<DateTime> doneDays, DateTime today) {
  final days = {for (final d in doneDays) dayKey(d)};
  var cursor = dayOf(today);
  if (!days.contains(dayKey(cursor))) {
    cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
  }
  var count = 0;
  while (days.contains(dayKey(cursor))) {
    count++;
    cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
  }
  return count;
}
