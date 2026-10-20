import 'package:detox/features/squad/domain/squad_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('invite codes are normalized to upper case without spaces', () {
    expect(SquadRules.normalizeInviteCode(' ab 12cd '), 'AB12CD');
  });

  test('invite code validation', () {
    expect(SquadRules.isValidInviteCode('AB12CD'), isTrue);
    expect(SquadRules.isValidInviteCode('ab12cd'), isTrue);
    expect(SquadRules.isValidInviteCode('AB12C'), isFalse);
    expect(SquadRules.isValidInviteCode('AB12CDE'), isFalse);
    expect(SquadRules.isValidInviteCode('AB-2CD'), isFalse);
  });
}
