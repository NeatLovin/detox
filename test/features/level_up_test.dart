import 'package:detox/features/gamification/presentation/level_up_dialog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('level up only on a real increase, never on first load', () {
    expect(isLevelUp(previousLevel: null, nextLevel: 5), isFalse);
    expect(isLevelUp(previousLevel: 4, nextLevel: 4), isFalse);
    expect(isLevelUp(previousLevel: 4, nextLevel: 5), isTrue);
    expect(isLevelUp(previousLevel: 5, nextLevel: 4), isFalse);
  });
}
