import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../domain/badges.dart';
import 'engagement_providers.dart';

/// All badges, unlocked ones in color. Tap one to see how to get it.
class BadgesGrid extends ConsumerWidget {
  const BadgesGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final unlocked = {
      for (final badge in ref.watch(myBadgesProvider).value ?? const <UnlockedBadge>[])
        badge.key: badge,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(l10n.badgesTitle, style: theme.textTheme.titleMedium),
                const Spacer(),
                Text(
                  l10n.badgesProgress(unlocked.length, BadgeKey.values.length),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final key in BadgeKey.values)
                  _BadgeTile(badgeKey: key, unlocked: unlocked[key]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badgeKey, required this.unlocked});

  final BadgeKey badgeKey;
  final UnlockedBadge? unlocked;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isUnlocked = unlocked != null;
    final name = l10n.badgeName(badgeKey.dbValue);
    return Tooltip(
      message: name,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('${badgeKey.emoji}  $name'),
            content: Text(
              [
                l10n.badgeDescription(badgeKey.dbValue),
                if (unlocked != null)
                  l10n.badgeUnlockedOn(formatDate(unlocked!.unlockedAt))
                else
                  l10n.badgeLocked,
              ].join('\n\n'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.commonContinue),
              ),
            ],
          ),
        ),
        child: Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isUnlocked
                ? AppColors.gold.withValues(alpha: 0.18)
                : AppColors.surface,
            border: Border.all(
              color: isUnlocked ? AppColors.gold : Colors.white12,
            ),
          ),
          child: Opacity(
            opacity: isUnlocked ? 1 : 0.25,
            child: Text(badgeKey.emoji, style: const TextStyle(fontSize: 26)),
          ),
        ),
      ),
    );
  }
}
