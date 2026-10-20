// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Profile _$ProfileFromJson(Map<String, dynamic> json) => _Profile(
  id: json['id'] as String,
  username: json['username'] as String,
  avatarEmoji: json['avatar_emoji'] as String,
  isPrivate: json['is_private'] as bool? ?? false,
  notifySos: json['notify_sos'] as bool? ?? true,
  notifyReminders: json['notify_reminders'] as bool? ?? true,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$ProfileToJson(_Profile instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'avatar_emoji': instance.avatarEmoji,
  'is_private': instance.isPrivate,
  'notify_sos': instance.notifySos,
  'notify_reminders': instance.notifyReminders,
  'created_at': instance.createdAt.toIso8601String(),
};
