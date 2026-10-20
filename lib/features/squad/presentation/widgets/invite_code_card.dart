import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/l10n/l10n.dart';
import '../../domain/squad.dart';

/// Big invite code with Copy and Share actions.
class InviteCodeCard extends StatelessWidget {
  const InviteCodeCard({super.key, required this.squad});

  final Squad squad;

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: squad.inviteCode));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(context.l10n.commonCopied)));
  }

  Future<void> _share(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(
      ShareParams(
        text: context.l10n.squadShareMessage(squad.name, squad.inviteCode),
        sharePositionOrigin: box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(l10n.squadCodeLabel, style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            SelectableText(
              squad.inviteCode,
              style: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 8,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _copy(context),
                    icon: const Icon(Icons.copy),
                    label: Text(l10n.commonCopy),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Builder(
                    builder: (buttonContext) => FilledButton.icon(
                      onPressed: () => _share(buttonContext),
                      icon: const Icon(Icons.share),
                      label: Text(l10n.commonShare),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
