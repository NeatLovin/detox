import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/error_messages.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/router/routes.dart';
import '../../addictions/domain/addiction.dart';
import '../../addictions/presentation/addiction_providers.dart';
import '../data/sos_repository.dart';

/// SOS button flow: pick the addiction (if several), alert everyone, then
/// open the SOS screen.
Future<void> launchSos(BuildContext context, WidgetRef ref) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final addictions = await ref.read(activeAddictionsProvider.future);
  if (!context.mounted) return;
  if (addictions.isEmpty) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.homeNoAddictions)));
    return;
  }

  final addiction = addictions.length == 1
      ? addictions.first
      : await showModalBottomSheet<Addiction>(
          context: context,
          useSafeArea: true,
          builder: (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                  child: Text(
                    l10n.sosPickAddiction,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                for (final a in addictions)
                  ListTile(
                    leading: const Icon(Icons.local_fire_department_outlined),
                    title: Text(a.label),
                    onTap: () => Navigator.pop(context, a),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
  if (addiction == null || !context.mounted) return;

  try {
    final alertId = await ref.read(sosRepositoryProvider).start(addiction.id);
    if (context.mounted) {
      await context.push(Routes.sos(alertId, addiction.id));
    }
  } catch (error) {
    messenger.showSnackBar(SnackBar(content: Text(errorMessage(l10n, error))));
  }
}
