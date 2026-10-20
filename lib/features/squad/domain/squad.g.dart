// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'squad.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Squad _$SquadFromJson(Map<String, dynamic> json) => _Squad(
  id: json['id'] as String,
  name: json['name'] as String,
  inviteCode: json['invite_code'] as String,
  createdBy: json['created_by'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$SquadToJson(_Squad instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'invite_code': instance.inviteCode,
  'created_by': instance.createdBy,
  'created_at': instance.createdAt.toIso8601String(),
};

_LeaderboardEntry _$LeaderboardEntryFromJson(Map<String, dynamic> json) =>
    _LeaderboardEntry(
      userId: json['user_id'] as String,
      username: json['username'] as String,
      avatarEmoji: json['avatar_emoji'] as String,
      level: (json['level'] as num).toInt(),
      hp: (json['hp'] as num).toInt(),
      xp: (json['xp'] as num).toInt(),
      weeklyXp: (json['weekly_xp'] as num).toInt(),
    );

Map<String, dynamic> _$LeaderboardEntryToJson(_LeaderboardEntry instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'username': instance.username,
      'avatar_emoji': instance.avatarEmoji,
      'level': instance.level,
      'hp': instance.hp,
      'xp': instance.xp,
      'weekly_xp': instance.weeklyXp,
    };
