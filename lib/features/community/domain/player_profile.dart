import '../../addictions/domain/addiction.dart';
import '../../gamification/domain/badges.dart';

/// Another player's public profile (from the `player_profile` RPC).
/// Private addictions are never included.
class PlayerProfile {
  const PlayerProfile({
    required this.userId,
    required this.username,
    required this.avatarEmoji,
    required this.isPrivate,
    required this.joinedAt,
    required this.level,
    required this.xp,
    required this.hp,
    this.rank,
    required this.badges,
    required this.addictions,
  });

  factory PlayerProfile.fromJson(Map<String, dynamic> json) => PlayerProfile(
    userId: json['user_id'] as String,
    username: json['username'] as String,
    avatarEmoji: json['avatar_emoji'] as String? ?? '😎',
    isPrivate: json['is_private'] as bool? ?? false,
    joinedAt: DateTime.parse(json['joined_at'] as String),
    level: (json['level'] as num?)?.toInt() ?? 1,
    xp: (json['xp'] as num?)?.toInt() ?? 0,
    hp: (json['hp'] as num?)?.toInt() ?? 100,
    rank: (json['rank'] as num?)?.toInt(),
    badges: [
      for (final raw in (json['badges'] as List? ?? const []))
        if (BadgeKey.fromDb((raw as Map)['key'] as String?) case final key?)
          UnlockedBadge(
            key: key,
            unlockedAt: DateTime.parse(raw['unlocked_at'] as String),
          ),
    ],
    addictions: [
      for (final raw in (json['addictions'] as List? ?? const []))
        Addiction.fromJson(Map<String, dynamic>.from(raw as Map)),
    ],
  );

  final String userId;
  final String username;
  final String avatarEmoji;
  final bool isPrivate;
  final DateTime joinedAt;
  final int level;
  final int xp;
  final int hp;
  final int? rank;
  final List<UnlockedBadge> badges;
  final List<Addiction> addictions;
}
