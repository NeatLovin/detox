import 'package:flutter/material.dart';

/// Picks a date then a time. The result is clamped to [last] (usually now),
/// so a past-only field can never end up in the future.
Future<DateTime?> pickPastDateTime(
  BuildContext context, {
  required DateTime initial,
  required DateTime first,
  required DateTime last,
}) async {
  final date = await showDatePicker(
    context: context,
    initialDate: initial.isAfter(last) ? last : initial,
    firstDate: first,
    lastDate: last,
  );
  if (date == null || !context.mounted) return null;
  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(initial),
  );
  if (time == null) return null;
  final picked = DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  );
  if (picked.isAfter(last)) return last;
  if (picked.isBefore(first)) return first;
  return picked;
}
