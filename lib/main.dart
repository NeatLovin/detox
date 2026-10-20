import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/env/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_CH');

  if (!Env.isConfigured) {
    debugPrint(
      'Missing SUPABASE_URL / SUPABASE_ANON_KEY. '
      'Run: flutter run --dart-define-from-file=env.json',
    );
    runApp(const ProviderScope(child: MissingEnvApp()));
    return;
  }

  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabaseAnonKey,
  );

  runApp(const ProviderScope(child: DetoxApp()));
}
