import 'package:flutter/material.dart';

import '../../core/errors/error_messages.dart';
import '../../core/l10n/l10n.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.emoji,
    required this.message,
    this.action,
  });

  final String emoji;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    );
  }
}

/// Friendly error with a retry button.
class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => EmptyState(
    emoji: '📡',
    message: errorMessage(context.l10n, error),
    action: OutlinedButton(
      onPressed: onRetry,
      child: Text(context.l10n.commonRetry),
    ),
  );
}
