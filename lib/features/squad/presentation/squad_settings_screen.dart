import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_messages.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/session/session_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../data/squad_repository.dart';
import '../domain/squad.dart';
import '../domain/squad_rules.dart';
import 'squad_providers.dart';
import 'widgets/invite_code_card.dart';

class SquadSettingsScreen extends ConsumerStatefulWidget {
  const SquadSettingsScreen({super.key});

  @override
  ConsumerState<SquadSettingsScreen> createState() =>
      _SquadSettingsScreenState();
}

class _SquadSettingsScreenState extends ConsumerState<SquadSettingsScreen> {
  bool _leaving = false;

  Future<void> _leave() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.squadLeaveConfirmTitle),
        content: Text(l10n.squadLeaveConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.squadLeave),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _leaving = true);
    try {
      await ref.read(squadRepositoryProvider).leaveSquad();
      // No squad anymore: the router sends the user back to the squad setup.
      ref.invalidate(currentSquadProvider);
    } catch (error) {
      if (!mounted) return;
      setState(() => _leaving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMessage(l10n, error))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final squad = ref.watch(currentSquadProvider).value;
    final members = ref.watch(squadMembersProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.squadSettingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (squad != null) ...[
            Text(
              squad.name,
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            InviteCodeCard(squad: squad),
          ],
          const SizedBox(height: 24),
          members.when(
            data: (list) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.squadMembersTitle(list.length),
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                for (final member in list)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Text(
                      member.avatarEmoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                    title: Text(member.username),
                    trailing: member.role == SquadRole.owner
                        ? Chip(
                            avatar: const Icon(Icons.star, size: 14),
                            label: Text(l10n.squadOwner),
                          )
                        : null,
                  ),
                if (list.length >= SquadRules.maxMembers)
                  Text(l10n.errorSquadFull, textAlign: TextAlign.center),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => ErrorState(
              error: error,
              onRetry: () => ref.invalidate(squadMembersProvider),
            ),
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: _leaving ? null : _leave,
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            icon: const Icon(Icons.logout),
            label: Text(l10n.squadLeave),
          ),
        ],
      ),
    );
  }
}
