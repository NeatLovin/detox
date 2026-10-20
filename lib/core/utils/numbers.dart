/// Parses user-entered decimals, accepting both "0.45" and "0,45".
double? parseDecimal(String input) {
  final normalized = input.trim().replaceAll(' ', '').replaceAll(',', '.');
  if (normalized.isEmpty) return null;
  final value = double.tryParse(normalized);
  if (value == null || value.isNaN || value.isInfinite || value < 0) {
    return null;
  }
  return value;
}

/// Formats a number for an input field ("0.45" → "0.45", "10.0" → "10").
String formatDecimalInput(double value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toStringAsFixed(2).replaceFirst(RegExp(r'0$'), '');
