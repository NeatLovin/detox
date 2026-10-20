import 'package:detox/features/addictions/domain/addiction.dart';
import 'package:detox/features/addictions/domain/addiction_limits.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const t = AddictionType.values;

  test('up to 6 active addictions', () {
    final five = [t[0], t[1], t[2], t[3], t[4]];
    expect(AddictionLimits.canAdd(five, AddictionType.sugar), isTrue);
    final six = [...five, AddictionType.sugar];
    expect(AddictionLimits.canAdd(six, AddictionType.alcohol), isFalse);
    expect(AddictionLimits.canAddAny(six), isFalse);
  });

  test('up to 2 custom addictions', () {
    const twoCustom = [AddictionType.custom, AddictionType.custom];
    expect(AddictionLimits.canAdd(twoCustom, AddictionType.custom), isFalse);
    expect(AddictionLimits.canAdd(twoCustom, AddictionType.snus), isTrue);
    expect(AddictionLimits.canAddAny(twoCustom), isTrue);
    expect(
      AddictionLimits.canAdd([AddictionType.custom], AddictionType.custom),
      isTrue,
    );
  });

  test('archived addictions do not count', () {
    Addiction addiction(AddictionType type, {bool archived = false}) =>
        Addiction(
          id: '$type$archived',
          userId: 'u',
          type: type,
          label: 'x',
          unitLabel: 'u',
          unitCost: 0,
          baselinePerDay: 1,
          quitStartedAt: DateTime.utc(2026),
          streakStartedAt: DateTime.utc(2026),
          archivedAt: archived ? DateTime.utc(2026, 2) : null,
          createdAt: DateTime.utc(2026),
        );
    final types = AddictionLimits.activeTypes([
      addiction(AddictionType.custom),
      addiction(AddictionType.custom, archived: true),
      addiction(AddictionType.snus),
    ]).toList();
    expect(types, [AddictionType.custom, AddictionType.snus]);
    expect(AddictionLimits.canAdd(types, AddictionType.custom), isTrue);
  });
}
