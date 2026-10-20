import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/session/session_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/xp_bar.dart';
import '../domain/leveling.dart';
import '../domain/player_stats.dart';

/// Avatar, username, level, animated XP bar and HP bar. Read-only: the
/// values come from player_stats, written by SQL triggers only.
class PlayerCard extends ConsumerWidget {
  const PlayerCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(playerStatsProvider, (previous, next) {
      final before = previous?.value?.level;
      final after = next.value?.level;
      if (before != null && after != null && after > before) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.playerLevelUp(after))),
        );
      }
    });

    final profile = ref.watch(currentProfileProvider).value;
    final stats =
        ref.watch(playerStatsProvider).value ??
        PlayerStats(userId: profile?.id ?? '');

    return PlayerCardView(
      username: profile?.username ?? '',
      avatarEmoji: profile?.avatarEmoji ?? '😎',
      stats: stats,
    );
  }
}

class PlayerCardView extends StatelessWidget {
  const PlayerCardView({
    super.key,
    required this.username,
    required this.avatarEmoji,
    required this.stats,
  });

  final String username;
  final String avatarEmoji;
  final PlayerStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final progress = LevelProgress.fromXp(stats.xp);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    border: Border.all(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    stats.isKo ? '😵' : avatarEmoji,
                    style: const TextStyle(fontSize: 30),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    username,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [theme.colorScheme.primary, AppColors.xp],
                        ),
                      ),
                      child: Text(
                        l10n.playerLevel(stats.level),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    )
                    .animate(key: ValueKey(stats.level))
                    .scale(
                      begin: const Offset(1.4, 1.4),
                      duration: 500.ms,
                      curve: Curves.elasticOut,
                    )
                    .shimmer(duration: 1200.ms),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.bolt, size: 16, color: AppColors.xp),
                const SizedBox(width: 4),
                Text('XP', style: theme.textTheme.labelMedium),
                const Spacer(),
                Text(
                  l10n.playerXpProgress(
                    progress.xpIntoLevel,
                    progress.xpForNextLevel,
                  ),
                  style: theme.textTheme.labelMedium,
                ),
              ],
            ),
            const SizedBox(height: 6),
            XpBar(ratio: progress.ratio),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.favorite, size: 16, color: AppColors.hp),
                const SizedBox(width: 4),
                Text('HP', style: theme.textTheme.labelMedium),
                const Spacer(),
                Text(
                  l10n.playerHp(stats.hp),
                  style: theme.textTheme.labelMedium,
                ),
              ],
            ),
            const SizedBox(height: 6),
            HpBar(hp: stats.hp),
            if (stats.isKo) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.hp.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(l10n.playerKo, textAlign: TextAlign.center),
              ).animate().fadeIn().shake(hz: 3, duration: 600.ms),
            ],
          ],
        ),
      ),
    );
  }
}
