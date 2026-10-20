import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/router/routes.dart';
import '../../../core/session/session_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../sos/presentation/community_sos_banner.dart';
import '../domain/leaderboard.dart';
import 'community_providers.dart';
import 'widgets/feed_tile.dart';
import 'widgets/podium.dart';

/// Opens a player's profile, or explains that it is private.
void openPlayer(BuildContext context, LeaderboardEntry entry, String? me) {
  if (entry.isPrivate && entry.userId != me) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.playerPrivate(entry.username))),
    );
    return;
  }
  context.push(Routes.player(entry.userId));
}

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(leaderboardProvider);
    ref.invalidate(communityFeedProvider);
    await ref.read(leaderboardProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // New feed events (XP earned, level up…) refresh the leaderboard.
    ref.listen(communityFeedProvider, (previous, next) {
      final before = previous?.value?.length;
      if (before != null &&
          next.value != null &&
          next.value!.length != before) {
        ref.invalidate(leaderboardProvider);
      }
    });

    final l10n = context.l10n;
    final theme = Theme.of(context);
    final me = ref.watch(authStateProvider).value;
    final leaderboard = ref.watch(leaderboardProvider);
    final feed = ref.watch(communityFeedProvider);
    final view = leaderboard.value;
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navCommunity)),
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            CommunitySosBanner(usernames: view?.usernames ?? const {}),
            Text(l10n.leaderboardTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            leaderboard.when(
              data: (view) => view.all.isEmpty
                  ? EmptyState(emoji: '🏁', message: l10n.leaderboardEmpty)
                  : Column(
                      children: [
                        Podium(
                          entries: view.podium,
                          currentUserId: me,
                          onTap: (e) => openPlayer(context, e, me),
                        ),
                        const SizedBox(height: 12),
                        for (final entry in view.others)
                          _RankRow(
                            entry: entry,
                            isMe: entry.userId == me,
                            onTap: () => openPlayer(context, entry, me),
                          ),
                      ],
                    ),
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
                          onTap: switch (view?.entryOf(event.userId)) {
                            final entry? => () => openPlayer(context, entry, me),
                            null => null,
                          },
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
                  onRetry: () => ref.invalidate(communityFeedProvider),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({required this.entry, required this.isMe, required this.onTap});

  final LeaderboardEntry entry;
  final bool isMe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isMe
            ? theme.colorScheme.primary.withValues(alpha: 0.18)
            : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: isMe
              ? BorderSide(color: theme.colorScheme.primary)
              : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 36,
                  child: Text('#${entry.rank}', style: theme.textTheme.labelLarge),
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
                if (entry.isPrivate) ...[
                  const Icon(Icons.lock, size: 14),
                  const SizedBox(width: 8),
                ],
                Text(
                  l10n.playerLevel(entry.level),
                  style: theme.textTheme.labelMedium,
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.leaderboardXp(entry.xp),
                  style: theme.textTheme.labelLarge?.copyWith(color: AppColors.xp),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
