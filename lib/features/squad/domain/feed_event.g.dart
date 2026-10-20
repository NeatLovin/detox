// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FeedEvent _$FeedEventFromJson(Map<String, dynamic> json) => _FeedEvent(
  id: json['id'] as String,
  squadId: json['squad_id'] as String,
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
      'squad_id': instance.squadId,
      'user_id': instance.userId,
      'type': _$FeedEventTypeEnumMap[instance.type]!,
      'payload': instance.payload,
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$FeedEventTypeEnumMap = {
  FeedEventType.joinedSquad: 'joined_squad',
  FeedEventType.leftSquad: 'left_squad',
  FeedEventType.milestone: 'milestone',
  FeedEventType.levelUp: 'level_up',
  FeedEventType.relapse: 'relapse',
  FeedEventType.unknown: 'unknown',
};
