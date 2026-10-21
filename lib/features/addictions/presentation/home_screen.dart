import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/router/routes.dart';
import '../../../core/session/session_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../cravings/presentation/craving_sheet.dart';
import '../../gamification/presentation/engagement_providers.dart';
import '../../gamification/presentation/pledge_card.dart';
import '../../gamification/presentation/player_card.dart';
import '../../sos/presentation/sos_launcher.dart';
import '../../updates/presentation/update_banner.dart';
import '../domain/addiction.dart';
import 'addiction_providers.dart';
import 'widgets/addiction_card.dart';
import 'widgets/relapse_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(myAddictionsProvider);
    ref.invalidate(playerStatsProvider);
    ref.invalidate(pledgedTodayProvider);
    ref.invalidate(latestReleaseProvider);
    await ref.read(activeAddictionsProvider.future);
  }

  Future<void> _logCraving(
    BuildContext context,
    WidgetRef ref,
    List<Addiction> addictions,
  ) async {
    final result = await showCravingSheet(context, addictions);
    if (result == null || !context.mounted) return;
    final (outcome, addiction) = result;
    // Gave in: offer the relapse flow right away (the user decides to share).
    if (outcome == CravingSheetResult.gaveIn) {
      await _relapse(context, ref, addiction);
    }
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

    final active = addictions.value ?? const <Addiction>[];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeGreeting(profile?.username ?? ''))),
      floatingActionButton: active.isEmpty
          ? null
          : FloatingActionButton.extended(
              heroTag: 'sos',
              backgroundColor: AppColors.hp,
              foregroundColor: Colors.white,
              onPressed: () => launchSos(context, ref),
              icon: const Icon(Icons.sos),
              label: Text(l10n.homeSosButton),
            ),
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          children: [
            const UpdateBanner(),
            const PlayerCard(),
            const SizedBox(height: 12),
            const PledgeCard(),
            if (active.isNotEmpty) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _logCraving(context, ref, active),
                icon: const Icon(Icons.edit_note),
                label: Text(l10n.homeLogCraving),
              ),
            ],
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
                              onOpenTimeline: () =>
                                  context.push(Routes.timeline(addiction.id)),
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
