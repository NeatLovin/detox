import 'package:freezed_annotation/freezed_annotation.dart';

part 'addiction.freezed.dart';
part 'addiction.g.dart';

/// Must match the CHECK constraint on `addictions.type`.
enum AddictionType {
  porn,
  snus,
  cigarette,
  vape,
  weed,
  alcohol,
  sugar,
  custom;

  String get dbValue => name;

  static AddictionType fromDb(String value) => AddictionType.values.firstWhere(
    (t) => t.name == value,
    orElse: () => AddictionType.custom,
  );
}

@freezed
abstract class Addiction with _$Addiction {
  const Addiction._();

  const factory Addiction({
    required String id,
    required String userId,
    @JsonKey(unknownEnumValue: AddictionType.custom)
    required AddictionType type,
    required String label,
    required String unitLabel,
    required double unitCost,
    required double baselinePerDay,
    @Default(false) bool isPrivate,
    required DateTime quitStartedAt,
    required DateTime streakStartedAt,
    @Default(0) int bestStreakSeconds,
    @Default(0) int awardedCleanDays,
    DateTime? archivedAt,
    required DateTime createdAt,
  }) = _Addiction;

  factory Addiction.fromJson(Map<String, dynamic> json) =>
      _$AddictionFromJson(json);

  bool get isArchived => archivedAt != null;
}

/// Client-side draft used to create or edit an addiction.
/// Only these fields are writable by the client (column grants in SQL).
@freezed
abstract class AddictionDraft with _$AddictionDraft {
  const factory AddictionDraft({
    required AddictionType type,
    required String label,
    required String unitLabel,
    required double unitCost,
    required double baselinePerDay,
    @Default(false) bool isPrivate,
    required DateTime quitStartedAt,
  }) = _AddictionDraft;
}

@freezed
abstract class RelapseInput with _$RelapseInput {
  const factory RelapseInput({
    required String addictionId,
    required DateTime occurredAt,
    String? note,
    @Default(false) bool shared,
  }) = _RelapseInput;
}
