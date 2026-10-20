import 'package:flutter/material.dart';

// This screen must render even when the rest of the app cannot start, so it
// depends on nothing but Flutter itself: no l10n delegates, no theme, no
// providers. Its strings are therefore hard-coded (French UI).

/// Minimal app shown when startup fails (bad config, Supabase init error, timeout).
class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({required this.title, required this.details, super.key});

  final String title;
  final String details;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
      home: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                const Text('🔧', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                SelectableText(details, style: const TextStyle(fontSize: 15)),
                const SizedBox(height: 24),
                const Text(
                  'Fais une capture de cet écran et envoie-la pour corriger le problème.',
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Replaces the release-mode grey box with the actual error message.
Widget buildReadableErrorWidget(FlutterErrorDetails details) {
  return Material(
    color: const Color(0xFF2B0B0B),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Text(
          'Erreur d’affichage :\n${details.exceptionAsString()}',
          style: const TextStyle(color: Colors.white, fontSize: 13),
          textDirection: TextDirection.ltr,
        ),
      ),
    ),
  );
}
