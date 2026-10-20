import 'package:flutter/material.dart';

/// Small spinner sized for a filled button while an action runs.
class ButtonSpinner extends StatelessWidget {
  const ButtonSpinner({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.square(
    dimension: 22,
    child: CircularProgressIndicator(strokeWidth: 2.5),
  );
}
