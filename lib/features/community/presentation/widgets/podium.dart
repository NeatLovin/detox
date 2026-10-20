import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/leaderboard.dart';

/// All-time top 3: 2nd · 1st · 3rd. Tap a step to open the player.
class Podium extends StatelessWidget {
  const Podium({
    super.key,
    required this.entries,
    required this.currentUserId,
    required this.onTap,
  });

  final List<LeaderboardEntry> entries;
  final String? currentUserId;
  final void Function(LeaderboardEntry entry) onTap;

  @override
  Widget build(BuildContext context) {
    const heights = [110.0, 80.0, 60.0];
    const colors = [AppColors.gold, AppColors.silver, AppColors.bronze];
    const medals = ['🥇', '🥈', '🥉'];
    // Visual order: 2nd, 1st, 3rd.
    final order = [1, 0, 2].where((i) => i < entries.length).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final i in order)
          Expanded(
            child:
                InkWell(
                      onTap: () => onTap(entries[i]),
                      borderRadius: BorderRadius.circular(14),
                      child: _PodiumStep(
                      entry: entries[i],
                      medal: medals[i],
                      color: colors[i],
                      height: heights[i],
                      isMe: entries[i].userId == currentUserId,
                    ),
                    )
                    .animate()
                    .fadeIn(delay: (150 * (2 - i)).ms)
                    .slideY(begin: 0.3, curve: Curves.easeOutBack),
          ),
      ],
    );
  }
}

class _PodiumStep extends StatelessWidget {
  const _PodiumStep({
    required this.entry,
    required this.medal,
    required this.color,
    required this.height,
    required this.isMe,
  });

  final LeaderboardEntry entry;
  final String medal;
  final Color color;
  final double height;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(entry.avatarEmoji, style: const TextStyle(fontSize: 36)),
          if (entry.isPrivate) const Icon(Icons.lock, size: 14),
          Text(
            isMe
                ? '${entry.username} (${l10n.leaderboardYou})'
                : entry.username,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: isMe ? FontWeight.w900 : FontWeight.w600,
              color: isMe ? theme.colorScheme.primary : null,
            ),
          ),
          Text(
            l10n.leaderboardXp(entry.xp),
            style: theme.textTheme.labelSmall?.copyWith(color: AppColors.xp),
          ),
          const SizedBox(height: 4),
          Container(
            height: height,
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withValues(alpha: 0.6),
                  color.withValues(alpha: 0.1),
                ],
              ),
              border: isMe
                  ? Border.all(color: theme.colorScheme.primary, width: 2)
                  : null,
            ),
            child: Text(medal, style: const TextStyle(fontSize: 28)),
          ),
        ],
      ),
    );
  }
}
