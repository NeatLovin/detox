import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/error_messages.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/router/routes.dart';
import '../../../core/session/session_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../addictions/data/addiction_repository.dart';
import '../../addictions/domain/addiction.dart';
import '../../addictions/domain/addiction_catalog.dart';
import '../../addictions/domain/addiction_limits.dart';
import '../../addictions/presentation/addiction_providers.dart';
import '../../auth/data/auth_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _archive(
    BuildContext context,
    WidgetRef ref,
    Addiction addiction,
  ) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.profileArchiveConfirmTitle(addiction.label)),
        content: Text(l10n.profileArchiveConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.profileArchive),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(addictionRepositoryProvider).archive(addiction.id);
      ref.invalidate(myAddictionsProvider);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMessage(l10n, error))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final profile = ref.watch(currentProfileProvider).value;
    final stats = ref.watch(playerStatsProvider).value;
    final addictions = ref.watch(myAddictionsProvider);
    final canAdd =
        addictions.hasValue &&
        AddictionLimits.canAddAny(
          AddictionLimits.activeTypes(addictions.requireValue),
        );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navProfile)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Text(
                profile?.avatarEmoji ?? '😎',
                style: const TextStyle(fontSize: 40),
              ),
              title: Text(
                profile?.username ?? '',
                style: theme.textTheme.titleLarge,
              ),
              subtitle: stats == null
                  ? null
                  : Text(l10n.profileStats(stats.level, stats.xp)),
              trailing: IconButton(
                tooltip: l10n.profileEdit,
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push(Routes.editProfile),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.profileAddictionsTitle,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              IconButton.filledTonal(
                tooltip: canAdd
                    ? l10n.homeAddAddiction
                    : l10n.errorTooManyAddictions,
                icon: const Icon(Icons.add),
                onPressed: canAdd
                    ? () => context.push(Routes.newAddiction)
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 8),
          addictions.when(
            data: (all) {
              final active = all.where((a) => !a.isArchived).toList();
              final archived = all.where((a) => a.isArchived).toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!canAdd)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        l10n.errorTooManyAddictions,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  if (active.isEmpty)
                    EmptyState(emoji: '🌱', message: l10n.homeNoAddictions),
                  for (final addiction in active)
                    _AddictionTile(
                      addiction: addiction,
                      onTap: () =>
                          context.push(Routes.editAddiction(addiction.id)),
                      onArchive: () => _archive(context, ref, addiction),
                    ),
                  if (archived.isNotEmpty)
                    ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      title: Text(
                        '${l10n.profileArchivedTitle} (${archived.length})',
                      ),
                      children: [
                        for (final addiction in archived)
                          _AddictionTile(addiction: addiction),
                      ],
                    ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => ErrorState(
              error: error,
              onRetry: () => ref.invalidate(myAddictionsProvider),
            ),
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
            icon: const Icon(Icons.logout),
            label: Text(l10n.profileSignOut),
          ),
        ],
      ),
    );
  }
}

class _AddictionTile extends StatelessWidget {
  const _AddictionTile({required this.addiction, this.onTap, this.onArchive});

  final Addiction addiction;
  final VoidCallback? onTap;
  final VoidCallback? onArchive;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      enabled: !addiction.isArchived,
      leading: Text(
        AddictionCatalog.of(addiction.type).emoji,
        style: const TextStyle(fontSize: 28),
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(addiction.label, overflow: TextOverflow.ellipsis),
          ),
          if (addiction.isPrivate) ...[
            const SizedBox(width: 6),
            const Icon(Icons.lock, size: 14),
          ],
        ],
      ),
      subtitle: Text(addiction.unitLabel),
      trailing: onArchive == null
          ? null
          : IconButton(
              tooltip: l10n.profileArchive,
              icon: const Icon(Icons.archive_outlined),
              onPressed: onArchive,
            ),
    );
  }
}
