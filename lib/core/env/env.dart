/// Compile-time configuration injected with `--dart-define-from-file=env.json`.
abstract final class Env {
  static const _rawSupabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const _rawSupabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Trimmed: a secret pasted with a trailing newline or space must not break startup.
  static String get supabaseUrl => normalizeUrl(_rawSupabaseUrl);
  static String get supabaseAnonKey => _rawSupabaseAnonKey.trim();

  /// Null when the configuration is usable, otherwise a human-readable reason
  /// (never contains the key itself).
  static String? get validationError =>
      validateConfig(url: _rawSupabaseUrl, anonKey: _rawSupabaseAnonKey);
}

/// Removes surrounding whitespace, quotes and trailing slashes.
String normalizeUrl(String raw) {
  var url = raw.trim();
  if (url.length >= 2 &&
      ((url.startsWith('"') && url.endsWith('"')) ||
          (url.startsWith("'") && url.endsWith("'")))) {
    url = url.substring(1, url.length - 1).trim();
  }
  while (url.endsWith('/')) {
    url = url.substring(0, url.length - 1);
  }
  return url;
}

/// Pure validation of the Supabase configuration, tested in test/core/env_test.dart.
String? validateConfig({required String url, required String anonKey}) {
  final normalizedUrl = normalizeUrl(url);
  final key = anonKey.trim();

  if (normalizedUrl.isEmpty || key.isEmpty) {
    return 'SUPABASE_URL ou SUPABASE_ANON_KEY est vide dans le build.';
  }
  final uri = Uri.tryParse(normalizedUrl);
  if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
    return 'SUPABASE_URL invalide : attendu https://<ref>.supabase.co '
        '(reçu ${normalizedUrl.length} caractères commençant par '
        '"${normalizedUrl.substring(0, normalizedUrl.length.clamp(0, 12))}").';
  }
  if (RegExp(r'\s').hasMatch(key)) {
    return 'SUPABASE_ANON_KEY contient des espaces ou des retours à la ligne.';
  }
  if (key.startsWith('sb_secret_')) {
    return 'SUPABASE_ANON_KEY est une clé secrète : utilise la clé publishable.';
  }
  if (!key.startsWith('sb_publishable_') && !key.startsWith('eyJ')) {
    return 'SUPABASE_ANON_KEY ne ressemble pas à une clé publishable '
        '(sb_publishable_…) ni à une clé anon (eyJ…).';
  }
  return null;
}
