// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlayerStats _$PlayerStatsFromJson(Map<String, dynamic> json) => _PlayerStats(
  userId: json['user_id'] as String,
  xp: (json['xp'] as num?)?.toInt() ?? 0,
  level: (json['level'] as num?)?.toInt() ?? 1,
  hp: (json['hp'] as num?)?.toInt() ?? 100,
);

Map<String, dynamic> _$PlayerStatsToJson(_PlayerStats instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'xp': instance.xp,
      'level': instance.level,
      'hp': instance.hp,
    };
