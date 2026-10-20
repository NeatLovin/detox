import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_messages.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/session/session_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/sos_repository.dart';
import '../domain/sos.dart';
import 'sos_providers.dart';

/// Open SOS of other players, with one-tap support. Hidden when there is none.
class CommunitySosBanner extends ConsumerWidget {
  const CommunitySosBanner({super.key, required this.usernames});

  /// user id → username, to name who needs help.
  final Map<String, String> usernames;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(authStateProvider).value;
    final now = DateTime.now();
    final alerts = (ref.watch(sosAlertsProvider).value ?? const <SosAlert>[])
        .where((a) => a.userId != me && a.isActive(now))
        .toList();
    if (alerts.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        for (final alert in alerts) ...[
          _SosCard(alert: alert, username: usernames[alert.userId] ?? '?'),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _SosCard extends ConsumerStatefulWidget {
  const _SosCard({required this.alert, required this.username});

  final SosAlert alert;
  final String username;

  @override
  ConsumerState<_SosCard> createState() => _SosCardState();
}

class _SosCardState extends ConsumerState<_SosCard> {
  String? _sent;
  bool _busy = false;

  Future<void> _support(String emoji) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await ref
          .read(sosRepositoryProvider)
          .support(alertId: widget.alert.id, emoji: emoji);
      if (!mounted) return;
      setState(() {
        _sent = emoji;
        _busy = false;
      });
      messenger.showSnackBar(SnackBar(content: Text(l10n.sosCardSent(emoji))));
    } catch (error) {
      if (!mounted) return;
      setState(() => _busy = false);
      messenger.showSnackBar(SnackBar(content: Text(errorMessage(l10n, error))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final mine = ref
        .watch(sosSupportsProvider(widget.alert.id))
        .value
        ?.where((s) => s.userId == ref.watch(authStateProvider).value)
        .firstOrNull;
    final sent = _sent ?? mine?.emoji;
    return Card(
      color: AppColors.hp.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.sos, color: AppColors.hp),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.sosCardTitle(widget.username, widget.alert.addictionLabel),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (sent != null)
              Text(l10n.sosCardSent(sent))
            else ...[
              Text(l10n.sosCardSupport),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final emoji in sosSupportEmojis)
                    ActionChip(
                      label: Text(emoji, style: const TextStyle(fontSize: 22)),
                      onPressed: _busy ? null : () => _support(emoji),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
