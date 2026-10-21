import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../addictions/domain/addiction.dart';
import '../../addictions/domain/addiction_progress.dart';
import '../data/health_timeline_providers.dart';
import '../domain/health_timeline.dart';

/// "dans 3 h", "dans 2 j"… for the next milestone.
String timeUntil(AppLocalizations l10n, Duration left) {
  if (left.inDays >= 1) return l10n.timelineInDays(left.inDays);
  if (left.inHours >= 1) return l10n.timelineInHours(left.inHours);
  return l10n.timelineInMinutes(left.inMinutes < 1 ? 1 : left.inMinutes);
}

/// "après 20 min", "après 3 j"… for a milestone of the list.
String afterLabel(AppLocalizations l10n, Duration after) {
  if (after.inDays >= 365) return l10n.timelineAfterYears(after.inDays ~/ 365);
  if (after.inDays >= 30) return l10n.timelineAfterMonths(after.inDays ~/ 30);
  if (after.inDays >= 7 && after.inDays % 7 == 0) return l10n.timelineAfterWeeks(after.inDays ~/ 7);
  if (after.inDays >= 1) return l10n.timelineAfterDays(after.inDays);
  if (after.inHours >= 1) return l10n.timelineAfterHours(after.inHours);
  return l10n.timelineAfterMinutes(after.inMinutes);
}

/// Compact line on the addiction card: next body/habit milestone.
class TimelineTeaser extends ConsumerWidget {
  const TimelineTeaser({
    super.key,
    required this.addiction,
    required this.now,
    required this.onTap,
  });

  final Addiction addiction;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final timeline = ref.watch(healthTimelinesProvider).value?.of(addiction.type);
    if (timeline == null) return const SizedBox.shrink();

    final clean = AddictionProgress.cleanDuration(addiction.streakStartedAt, now);
    final next = timeline.next(clean);
    final latest = timeline.latest(clean);
    final text = next != null
        ? '${next.emoji} ${next.title} · ${timeUntil(l10n, next.after - clean)}'
        : '${latest?.emoji ?? '🏆'} ${l10n.timelineAllReached}';

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(
              timeline.kind == TimelineKind.body ? Icons.favorite_outline : Icons.timeline,
              size: 16,
              color: AppColors.hp,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ),
            const Icon(Icons.chevron_right, size: 18),
          ],
        ),
      ),
    );
  }
}
