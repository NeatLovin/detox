import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';

/// "Développé par NeatLovin", shown under the Detox logo.
class BrandSubtitle extends StatelessWidget {
  const BrandSubtitle({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      context.l10n.brandDevelopedBy,
      textAlign: TextAlign.center,
      style: theme.textTheme.labelMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        letterSpacing: 0.8,
      ),
    );
  }
}
