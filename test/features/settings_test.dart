import 'package:detox/features/settings/domain/settings_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AccountDeletion', () {
    test('needs the confirmation word', () {
      expect(AccountDeletion.isConfirmed('SUPPRIMER'), isTrue);
      expect(AccountDeletion.isConfirmed('  supprimer '), isTrue);
      expect(AccountDeletion.isConfirmed(''), isFalse);
      expect(AccountDeletion.isConfirmed('SUPPRIME'), isFalse);
      expect(AccountDeletion.isConfirmed('oui'), isFalse);
    });
  });

  group('TwintDonation', () {
    test('normalize keeps digits and a leading +', () {
      expect(TwintDonation.normalize('079 123 45 67'), '0791234567');
      expect(TwintDonation.normalize(' +41 79 123-45-67 '), '+41791234567');
    });

    test('format writes Swiss numbers by blocks', () {
      expect(TwintDonation.format('0791234567'), '079 123 45 67');
      expect(TwintDonation.format('+41791234567'), '+41 79 123 45 67');
      expect(TwintDonation.format('+41 79 123 45 67'), '+41 79 123 45 67');
    });

    test('format leaves other shapes as typed', () {
      expect(TwintDonation.format(' +33 6 12 34 56 78 '), '+33 6 12 34 56 78');
      expect(TwintDonation.format('12345'), '12345');
    });
  });
}
