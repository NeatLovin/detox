import 'package:detox/core/env/env.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const url = 'https://nljatsevcqlvqcmotyhl.supabase.co';
  const key = 'sb_publishable_abc123';

  group('normalizeUrl', () {
    test('trims whitespace, newlines, quotes and trailing slashes', () {
      expect(normalizeUrl('  $url \n'), url);
      expect(normalizeUrl('"$url/"'), url);
      expect(normalizeUrl("'$url//'"), url);
    });
  });

  group('validateConfig', () {
    test('accepts a publishable key and a legacy anon key', () {
      expect(validateConfig(url: url, anonKey: key), isNull);
      expect(validateConfig(url: url, anonKey: 'eyJhbGciOi.payload.sig'), isNull);
    });

    test('tolerates surrounding whitespace pasted with the secrets', () {
      expect(validateConfig(url: '$url\n', anonKey: ' $key\n'), isNull);
    });

    test('rejects empty values', () {
      expect(validateConfig(url: '', anonKey: key), isNotNull);
      expect(validateConfig(url: url, anonKey: '   '), isNotNull);
    });

    test('rejects a url without https scheme or host', () {
      expect(validateConfig(url: 'nljatsevcqlvqcmotyhl', anonKey: key), isNotNull);
      expect(validateConfig(url: 'http://x.supabase.co', anonKey: key), isNotNull);
    });

    test('rejects a key with inner whitespace', () {
      expect(validateConfig(url: url, anonKey: 'sb_publishable_ab c'), isNotNull);
    });

    test('rejects a secret key with a dedicated message', () {
      final error = validateConfig(url: url, anonKey: 'sb_secret_xyz');
      expect(error, contains('clé secrète'));
    });

    test('never leaks the key in the message', () {
      final error = validateConfig(url: url, anonKey: 'not-a-real-key-123');
      expect(error, isNotNull);
      expect(error, isNot(contains('not-a-real-key-123')));
    });
  });
}
