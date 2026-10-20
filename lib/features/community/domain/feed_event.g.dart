// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FeedEvent _$FeedEventFromJson(Map<String, dynamic> json) => _FeedEvent(
  id: json['id'] as String,
  userId: json['user_id'] as String?,
  type: $enumDecode(
    _$FeedEventTypeEnumMap,
    json['type'],
    unknownValue: FeedEventType.unknown,
  ),
  payload:
      json['payload'] as Map<String, dynamic>? ?? const <String, dynamic>{},
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$FeedEventToJson(_FeedEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'type': _$FeedEventTypeEnumMap[instance.type]!,
      'payload': instance.payload,
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$FeedEventTypeEnumMap = {
  FeedEventType.joined: 'joined',
  FeedEventType.milestone: 'milestone',
  FeedEventType.levelUp: 'level_up',
  FeedEventType.relapse: 'relapse',
  FeedEventType.pledge: 'pledge',
  FeedEventType.badge: 'badge',
  FeedEventType.sos: 'sos',
  FeedEventType.sosSupport: 'sos_support',
  FeedEventType.sosResolved: 'sos_resolved',
  FeedEventType.questsAllDone: 'quests_all_done',
  FeedEventType.unknown: 'unknown',
};
