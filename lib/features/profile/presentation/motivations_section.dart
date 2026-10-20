import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_messages.dart';
import '../../../core/l10n/l10n.dart';
import '../data/motivation_repository.dart';

/// "My reasons to quit" (max 5), shown on the SOS screen.
class MotivationsSection extends ConsumerWidget {
  const MotivationsSection({super.key});

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref, {
    Motivation? motivation,
  }) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final controller = TextEditingController(text: motivation?.text ?? '');
    final text = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(motivation == null ? l10n.motivationsAdd : l10n.commonEdit),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 140,
          maxLines: 3,
          minLines: 1,
          decoration: InputDecoration(hintText: l10n.motivationsHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );
    if (text == null || text.trim().isEmpty) return;
    try {
      final repo = ref.read(motivationRepositoryProvider);
      if (motivation == null) {
        await repo.add(text);
      } else {
        await repo.update(motivation.id, text);
      }
      ref.invalidate(myMotivationsProvider);
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(errorMessage(l10n, error))));
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Motivation m) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(motivationRepositoryProvider).delete(m.id);
      ref.invalidate(myMotivationsProvider);
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(errorMessage(l10n, error))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final motivations = ref.watch(myMotivationsProvider).value ?? const <Motivation>[];

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.motivationsTitle, style: theme.textTheme.titleMedium),
            Text(l10n.motivationsSubtitle, style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            if (motivations.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(l10n.motivationsEmpty),
              ),
            for (final m in motivations)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.favorite_outline),
                title: Text(m.text),
                onTap: () => _edit(context, ref, motivation: m),
                trailing: IconButton(
                  tooltip: l10n.commonDelete,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _delete(context, ref, m),
                ),
              ),
            if (motivations.length < maxMotivations)
              TextButton.icon(
                onPressed: () => _edit(context, ref),
                icon: const Icon(Icons.add),
                label: Text(l10n.motivationsAdd),
              ),
          ],
        ),
      ),
    );
  }
}
