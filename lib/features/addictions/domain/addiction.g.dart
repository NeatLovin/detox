// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'addiction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Addiction _$AddictionFromJson(Map<String, dynamic> json) => _Addiction(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  type: $enumDecode(
    _$AddictionTypeEnumMap,
    json['type'],
    unknownValue: AddictionType.custom,
  ),
  label: json['label'] as String,
  unitLabel: json['unit_label'] as String,
  unitCost: (json['unit_cost'] as num).toDouble(),
  baselinePerDay: (json['baseline_per_day'] as num).toDouble(),
  isPrivate: json['is_private'] as bool? ?? false,
  quitStartedAt: DateTime.parse(json['quit_started_at'] as String),
  streakStartedAt: DateTime.parse(json['streak_started_at'] as String),
  bestStreakSeconds: (json['best_streak_seconds'] as num?)?.toInt() ?? 0,
  awardedCleanDays: (json['awarded_clean_days'] as num?)?.toInt() ?? 0,
  archivedAt: json['archived_at'] == null
      ? null
      : DateTime.parse(json['archived_at'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$AddictionToJson(_Addiction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'type': _$AddictionTypeEnumMap[instance.type]!,
      'label': instance.label,
      'unit_label': instance.unitLabel,
      'unit_cost': instance.unitCost,
      'baseline_per_day': instance.baselinePerDay,
      'is_private': instance.isPrivate,
      'quit_started_at': instance.quitStartedAt.toIso8601String(),
      'streak_started_at': instance.streakStartedAt.toIso8601String(),
      'best_streak_seconds': instance.bestStreakSeconds,
      'awarded_clean_days': instance.awardedCleanDays,
      'archived_at': instance.archivedAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$AddictionTypeEnumMap = {
  AddictionType.porn: 'porn',
  AddictionType.snus: 'snus',
  AddictionType.cigarette: 'cigarette',
  AddictionType.vape: 'vape',
  AddictionType.weed: 'weed',
  AddictionType.alcohol: 'alcohol',
  AddictionType.sugar: 'sugar',
  AddictionType.custom: 'custom',
};
