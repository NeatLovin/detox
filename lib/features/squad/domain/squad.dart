import 'package:freezed_annotation/freezed_annotation.dart';

part 'squad.freezed.dart';
part 'squad.g.dart';

@freezed
abstract class Squad with _$Squad {
  const factory Squad({
    required String id,
    required String name,
    required String inviteCode,
    String? createdBy,
    required DateTime createdAt,
  }) = _Squad;

  factory Squad.fromJson(Map<String, dynamic> json) => _$SquadFromJson(json);
}

enum SquadRole { owner, member }

@freezed
abstract class SquadMember with _$SquadMember {
  const factory SquadMember({
    required String userId,
    required String username,
    required String avatarEmoji,
    required SquadRole role,
    required DateTime joinedAt,
  }) = _SquadMember;
}

@freezed
abstract class LeaderboardEntry with _$LeaderboardEntry {
  const factory LeaderboardEntry({
    required String userId,
    required String username,
    required String avatarEmoji,
    required int level,
    required int hp,
    required int xp,
    required int weeklyXp,
  }) = _LeaderboardEntry;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardEntryFromJson(json);
}
