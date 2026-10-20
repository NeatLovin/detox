import 'package:intl/intl.dart';

const _locale = 'fr_CH';

String formatDateTime(DateTime value) =>
    DateFormat('d MMM yyyy · HH:mm', _locale).format(value.toLocal());

String formatChf(double amount) =>
    '${NumberFormat('#,##0.00', _locale).format(amount)} CHF';

String formatCount(num value) =>
    NumberFormat('#,##0', _locale).format(value.floor());
