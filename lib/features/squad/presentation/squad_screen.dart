import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/router/routes.dart';
import '../../../core/session/session_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/empty_state.dart';
import '../domain/leaderboard.dart';
import '../domain/squad.dart';
import 'squad_providers.dart';
import 'widgets/feed_tile.dart';
import 'widgets/podium.dart';

class SquadScreen extends ConsumerWidget {
  const SquadScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(leaderboardProvider);
    ref.invalidate(squadFeedProvider);
    await ref.read(leaderboardProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // New feed events (XP earned, level up…) refresh the leaderboard.
    ref.listen(squadFeedProvider, (previous, next) {
      final before = previous?.value?.length;
      if (before != null &&
          next.value != null &&
          next.value!.length != before) {
        ref.invalidate(leaderboardProvider);
      }
    });

    final l10n = context.l10n;
    final theme = Theme.of(context);
    final squad = ref.watch(currentSquadProvider).value;
    final userId = ref.watch(authStateProvider).value;
    final leaderboard = ref.watch(leaderboardProvider);
    final feed = ref.watch(squadFeedProvider);
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text(squad?.name ?? l10n.navSquad),
        actions: [
          IconButton(
            tooltip: l10n.squadSettingsTitle,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(Routes.squadSettings),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text(l10n.leaderboardTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            leaderboard.when(
              data: (view) => _LeaderboardSection(view: view, userId: userId),
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => ErrorState(
                error: error,
                onRetry: () => ref.invalidate(leaderboardProvider),
              ),
            ),
            const SizedBox(height: 24),
            Text(l10n.feedTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            ...feed.when(
              data: (events) => events.isEmpty
                  ? [EmptyState(emoji: '📭', message: l10n.feedEmpty)]
                  : [
                      for (final event in events)
                        FeedTile(
                          key: ValueKey(event.id),
                          event: event,
                          now: now,
                        ),
                    ],
              loading: () => const [
                Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
              error: (error, _) => [
                ErrorState(
                  error: error,
                  onRetry: () => ref.invalidate(squadFeedProvider),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardSection extends StatelessWidget {
  const _LeaderboardSection({required this.view, required this.userId});

  final LeaderboardView view;
  final String? userId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Podium(entries: view.podium, currentUserId: userId),
        const SizedBox(height: 12),
        for (final (index, entry) in view.others.indexed)
          _RankRow(rank: index + 4, entry: entry, isMe: entry.userId == userId),
      ],
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({required this.rank, required this.entry, required this.isMe});

  final int rank;
  final LeaderboardEntry entry;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isMe
            ? theme.colorScheme.primary.withValues(alpha: 0.18)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: isMe ? Border.all(color: theme.colorScheme.primary) : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text('#$rank', style: theme.textTheme.labelLarge),
          ),
          Text(entry.avatarEmoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isMe
                  ? '${entry.username} (${l10n.leaderboardYou})'
                  : entry.username,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: isMe ? FontWeight.w800 : null),
            ),
          ),
          Text(
            l10n.playerLevel(entry.level),
            style: theme.textTheme.labelMedium,
          ),
          const SizedBox(width: 12),
          Text(
            l10n.leaderboardXp(entry.weeklyXp),
            style: theme.textTheme.labelLarge?.copyWith(color: AppColors.xp),
          ),
        ],
      ),
    );
  }
}
