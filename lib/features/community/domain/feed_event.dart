import 'package:freezed_annotation/freezed_annotation.dart';

part 'feed_event.freezed.dart';
part 'feed_event.g.dart';

enum FeedEventType {
  @JsonValue('joined')
  joined,
  @JsonValue('milestone')
  milestone,
  @JsonValue('level_up')
  levelUp,
  @JsonValue('relapse')
  relapse,
  @JsonValue('pledge')
  pledge,
  @JsonValue('badge')
  badge,
  @JsonValue('sos')
  sos,
  @JsonValue('sos_support')
  sosSupport,
  @JsonValue('sos_resolved')
  sosResolved,
  @JsonValue('quests_all_done')
  questsAllDone,
  unknown,
}

/// Global feed event. The payload is built server side; a private addiction
/// never exposes its label, and a private player's events are not readable
/// by others (RLS).
@freezed
abstract class FeedEvent with _$FeedEvent {
  const FeedEvent._();

  const factory FeedEvent({
    required String id,
    String? userId,
    @JsonKey(unknownEnumValue: FeedEventType.unknown)
    required FeedEventType type,
    @Default(<String, dynamic>{}) Map<String, dynamic> payload,
    required DateTime createdAt,
  }) = _FeedEvent;

  factory FeedEvent.fromJson(Map<String, dynamic> json) =>
      _$FeedEventFromJson(json);

  String get username => payload['username'] as String? ?? '?';
  String get avatarEmoji => payload['avatar_emoji'] as String? ?? '👤';
  String? get addictionLabel => payload['addiction_label'] as String?;
  int? get days => (payload['days'] as num?)?.toInt();
  int? get bonusXp => (payload['bonus_xp'] as num?)?.toInt();
  int? get level => (payload['level'] as num?)?.toInt();
  String? get badge => payload['badge'] as String?;
  String? get emoji => payload['emoji'] as String?;
  String? get toUsername => payload['to_username'] as String?;
}
