import 'addiction.dart';

/// Anti-farming cap. Mirrors private.on_addiction_cap_before_insert in SQL:
/// max [maxActive] active addictions per user, of which max [maxCustom] custom.
abstract final class AddictionLimits {
  static const maxActive = 6;
  static const maxCustom = 2;

  /// Whether one more addiction of [type] can be added on top of [types]
  /// (the types of the user's active addictions).
  static bool canAdd(Iterable<AddictionType> types, AddictionType type) {
    final list = types.toList();
    if (list.length >= maxActive) return false;
    if (type == AddictionType.custom &&
        list.where((t) => t == AddictionType.custom).length >= maxCustom) {
      return false;
    }
    return true;
  }

  /// Whether any addiction can still be added.
  static bool canAddAny(Iterable<AddictionType> types) =>
      AddictionType.values.any((type) => canAdd(types, type));

  static Iterable<AddictionType> activeTypes(Iterable<Addiction> addictions) =>
      addictions.where((a) => !a.isArchived).map((a) => a.type);
}
