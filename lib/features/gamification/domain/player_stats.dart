import 'package:freezed_annotation/freezed_annotation.dart';

part 'player_stats.freezed.dart';
part 'player_stats.g.dart';

/// Read-only on the client: written exclusively by SQL triggers.
@freezed
abstract class PlayerStats with _$PlayerStats {
  const PlayerStats._();

  const factory PlayerStats({
    required String userId,
    @Default(0) int xp,
    @Default(1) int level,
    @Default(100) int hp,
  }) = _PlayerStats;

  factory PlayerStats.fromJson(Map<String, dynamic> json) =>
      _$PlayerStatsFromJson(json);

  bool get isKo => hp <= 0;
}
