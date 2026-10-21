import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/env/env.dart';
import 'core/startup/startup_error_app.dart';
import 'features/diagnostics/data/crash_repository.dart';
import 'features/diagnostics/data/error_reporter.dart';

/// Anything that throws or hangs before runApp() leaves the user frozen on the
/// native splash icon, with no way to know why. Every startup step is therefore
/// guarded and bounded in time, and a failure shows a readable error screen.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Release builds render a blank grey box on build errors: show the message.
  ErrorWidget.builder = buildReadableErrorWidget;

  try {
    await initializeDateFormatting('fr_CH');

    final envError = Env.validationError;
    if (envError != null) {
      runApp(
        ProviderScope(
          child: StartupErrorApp(title: 'Configuration invalide', details: envError),
        ),
      );
      return;
    }

    await Supabase.initialize(
      url: Env.supabaseUrl,
      publishableKey: Env.supabaseAnonKey,
    ).timeout(const Duration(seconds: 15));
  } on TimeoutException {
    runApp(
      const ProviderScope(
        child: StartupErrorApp(
          title: 'Démarrage trop long',
          details: 'La connexion à Supabase n’a pas abouti en 15 secondes. '
              'Vérifie ta connexion internet puis relance l’app.',
        ),
      ),
    );
    return;
  } catch (error, stack) {
    debugPrint('Startup failed: $error\n$stack');
    runApp(
      ProviderScope(
        child: StartupErrorApp(title: 'Erreur au démarrage', details: '$error'),
      ),
    );
    return;
  }

  final reporter = ErrorReporter(
    CrashRepository(Supabase.instance.client, build: Env.buildNumber),
  )..install();

  runApp(
    ProviderScope(
      observers: [ErrorReportingObserver(reporter)],
      child: const DetoxApp(),
    ),
  );
}
