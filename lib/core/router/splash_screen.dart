import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/brand_subtitle.dart';
import '../errors/error_messages.dart';
import '../l10n/l10n.dart';
import '../session/session_gate.dart';
import '../session/session_providers.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gate = ref.watch(sessionGateProvider);
    final l10n = context.l10n;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: gate == SessionGate.error
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('📡', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 16),
                    Text(
                      errorMessage(l10n, ref.read(currentProfileProvider).error),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () => ref.invalidate(currentProfileProvider),
                      child: Text(l10n.commonRetry),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/brand/logo.png', width: 120, height: 120),
                    const SizedBox(height: 12),
                    Text(
                      l10n.appTitle,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const BrandSubtitle(),
                    const SizedBox(height: 24),
                    const CircularProgressIndicator(),
                  ],
                ),
        ),
      ),
    );
  }
}
