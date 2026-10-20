import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/router/routes.dart';
import '../../../core/session/session_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../gamification/presentation/player_card.dart';
import '../domain/addiction.dart';
import 'addiction_providers.dart';
import 'widgets/addiction_card.dart';
import 'widgets/relapse_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(myAddictionsProvider);
    ref.invalidate(playerStatsProvider);
    await ref.read(activeAddictionsProvider.future);
  }

  Future<void> _relapse(
    BuildContext context,
    WidgetRef ref,
    Addiction addiction,
  ) async {
    final saved = await showRelapseSheet(context, addiction);
    if (!saved || !context.mounted) return;
    ref.invalidate(myAddictionsProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.relapseKindMessage),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final profile = ref.watch(currentProfileProvider).value;
    final addictions = ref.watch(activeAddictionsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeGreeting(profile?.username ?? ''))),
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const PlayerCard(),
            const SizedBox(height: 16),
            ...addictions.when(
              data: (items) => items.isEmpty
                  ? [
                      EmptyState(
                        emoji: '🌱',
                        message: l10n.homeNoAddictions,
                        action: FilledButton.icon(
                          onPressed: () => context.push(Routes.newAddiction),
                          icon: const Icon(Icons.add),
                          label: Text(l10n.homeAddAddiction),
                        ),
                      ),
                    ]
                  : [
                      for (final (index, addiction) in items.indexed) ...[
                        AddictionCard(
                              key: ValueKey(addiction.id),
                              addiction: addiction,
                              onRelapse: () =>
                                  _relapse(context, ref, addiction),
                            )
                            .animate()
                            .fadeIn(delay: (80 * index).ms)
                            .slideY(begin: 0.1),
                        const SizedBox(height: 12),
                      ],
                    ],
              loading: () => const [
                Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
              error: (error, _) => [
                ErrorState(
                  error: error,
                  onRetry: () => ref.invalidate(myAddictionsProvider),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
