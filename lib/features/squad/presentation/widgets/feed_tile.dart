import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/time_ago.dart';
import '../../domain/feed_event.dart';

class FeedTile extends StatelessWidget {
  const FeedTile({super.key, required this.event, required this.now});

  final FeedEvent event;
  final DateTime now;

  static (IconData, Color) _iconFor(FeedEventType type) => switch (type) {
    FeedEventType.joinedSquad => (Icons.waving_hand, AppColors.money),
    FeedEventType.leftSquad => (Icons.logout, AppColors.silver),
    FeedEventType.milestone => (Icons.emoji_events, AppColors.gold),
    FeedEventType.levelUp => (Icons.keyboard_double_arrow_up, AppColors.xp),
    FeedEventType.relapse => (Icons.favorite, AppColors.hp),
    FeedEventType.unknown => (Icons.bolt, AppColors.silver),
  };

  static String textFor(AppLocalizations l10n, FeedEvent event) {
    final label = event.addictionLabel ?? '';
    return switch (event.type) {
      FeedEventType.joinedSquad => l10n.feedJoined(event.username),
      FeedEventType.leftSquad => l10n.feedLeft(event.username),
      FeedEventType.milestone => l10n.feedMilestone(
        event.username,
        event.days ?? 0,
        label,
      ),
      FeedEventType.levelUp => l10n.feedLevelUp(
        event.username,
        event.level ?? 1,
      ),
      FeedEventType.relapse => l10n.feedRelapse(event.username, label),
      FeedEventType.unknown => l10n.feedUnknown(event.username),
    };
  }

  static String timeAgoText(AppLocalizations l10n, TimeAgo ago) =>
      switch (ago.unit) {
        TimeAgoUnit.now => l10n.timeAgoNow,
        TimeAgoUnit.minutes => l10n.timeAgoMinutes(ago.value),
        TimeAgoUnit.hours => l10n.timeAgoHours(ago.value),
        TimeAgoUnit.days => l10n.timeAgoDays(ago.value),
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (icon, color) = _iconFor(event.type);
    final bonus = event.type == FeedEventType.milestone ? event.bonusXp : null;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.15),
            child: Text(
              event.avatarEmoji,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          Positioned(
            right: -4,
            bottom: -4,
            child: CircleAvatar(
              radius: 10,
              backgroundColor: color,
              child: Icon(icon, size: 12, color: Colors.black),
            ),
          ),
        ],
      ),
      title: Text(textFor(l10n, event)),
      subtitle: Text(timeAgoText(l10n, TimeAgo.between(event.createdAt, now))),
      trailing: bonus == null
          ? null
          : Text(
              l10n.cardMilestoneBonus(bonus),
              style: const TextStyle(
                color: AppColors.xp,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}
