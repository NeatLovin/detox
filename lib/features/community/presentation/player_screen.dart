import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_messages.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/stat_tile.dart';
import '../../addictions/presentation/widgets/addiction_card.dart';
import '../../gamification/domain/badges.dart';
import '../domain/player_profile.dart';
import 'community_providers.dart';

/// Someone's public profile: level, XP, HP, badges and non-private addictions.
class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final player = ref.watch(playerProfileProvider(userId));

    return Scaffold(
      appBar: AppBar(title: Text(player.value?.username ?? '')),
      body: player.when(
        data: (p) => RefreshIndicator(
          onRefresh: () => ref.refresh(playerProfileProvider(userId).future),
          child: _PlayerBody(player: p),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => errorCode(error) == 'profile_private'
            ? EmptyState(emoji: '🔒', message: l10n.playerPrivateBody)
            : ErrorState(
                error: error,
                onRetry: () => ref.invalidate(playerProfileProvider(userId)),
              ),
      ),
    );
  }
}

class _PlayerBody extends ConsumerWidget {
  const _PlayerBody({required this.player});

  final PlayerProfile player;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final now = ref.watch(nowTickerProvider).value ?? DateTime.now();
    final unlocked = {for (final b in player.badges) b.key};

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(player.avatarEmoji, style: const TextStyle(fontSize: 56)),
                Text(player.username, style: theme.textTheme.headlineMedium),
                Text(
                  l10n.playerSince(formatDate(player.joinedAt)),
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        icon: Icons.military_tech_outlined,
                        label: l10n.playerRankLabel,
                        value: player.rank == null ? '—' : '#${player.rank}',
                        color: AppColors.gold,
                      ),
                    ),
                    Expanded(
                      child: StatTile(
                        icon: Icons.keyboard_double_arrow_up,
                        label: l10n.playerLevelLabel,
                        value: '${player.level}',
                        color: AppColors.xp,
                      ),
                    ),
                    Expanded(
                      child: StatTile(
                        icon: Icons.bolt,
                        label: 'XP',
                        value: formatCount(player.xp),
                        color: AppColors.xp,
                      ),
                    ),
                    Expanded(
                      child: StatTile(
                        icon: Icons.favorite,
                        label: 'HP',
                        value: '${player.hp}',
                        color: AppColors.hp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.badgesTitle} · '
                  '${l10n.badgesProgress(unlocked.length, BadgeKey.values.length)}',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                if (unlocked.isEmpty)
                  Text(l10n.playerNoBadges)
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final key in BadgeKey.values.where(unlocked.contains))
                        Tooltip(
                          message: l10n.badgeName(key.dbValue),
                          child: Chip(
                            avatar: Text(key.emoji),
                            label: Text(l10n.badgeName(key.dbValue)),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(l10n.playerAddictionsTitle, style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        if (player.addictions.isEmpty)
          EmptyState(emoji: '🌱', message: l10n.playerNoAddictions)
        else
          for (final addiction in player.addictions) ...[
            AddictionCardView(addiction: addiction, now: now),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}
