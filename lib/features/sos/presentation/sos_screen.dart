import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_messages.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/session/session_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/button_spinner.dart';
import '../../addictions/presentation/addiction_providers.dart';
import '../../addictions/presentation/widgets/relapse_sheet.dart';
import '../../cravings/domain/craving.dart';
import '../../cravings/presentation/craving_providers.dart';
import '../../profile/data/motivation_repository.dart';
import '../data/sos_repository.dart';
import '../domain/sos.dart';
import 'sos_providers.dart';

/// Full-screen SOS: countdown, paced breathing, the user's reasons, grounding
/// exercise and live support from the squad.
class SosScreen extends ConsumerStatefulWidget {
  const SosScreen({super.key, required this.alertId, this.addictionId});

  final String alertId;
  final String? addictionId;

  @override
  ConsumerState<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends ConsumerState<SosScreen>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _elapsed = Duration.zero;
  int _intensity = 3;
  bool _busy = false;
  bool _resolved = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) => setState(() => _elapsed = elapsed))
      ..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  Future<void> _resolve({required bool resisted}) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    try {
      await ref
          .read(sosRepositoryProvider)
          .resolve(
            alertId: widget.alertId,
            resisted: resisted,
            intensity: _intensity,
            trigger: CravingTrigger.other,
          );
      _resolved = true;
      ref.invalidate(recentCravingsProvider);
      ref.invalidate(playerStatsProvider);
      if (resisted) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.sosVictory)));
        navigator.pop();
        return;
      }
      final addictions = await ref.read(activeAddictionsProvider.future);
      final addiction = addictions
          .where((a) => a.id == widget.addictionId)
          .firstOrNull;
      // This screen is disposed by pop(): keep the container, not `ref`.
      if (!mounted) return;
      final container = ProviderScope.containerOf(context, listen: false);
      navigator.pop();
      if (addiction != null && navigator.context.mounted) {
        final saved = await showRelapseSheet(navigator.context, addiction);
        if (saved) {
          container.invalidate(myAddictionsProvider);
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.relapseKindMessage)),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() => _busy = false);
        messenger.showSnackBar(
          SnackBar(content: Text(errorMessage(l10n, error))),
        );
      }
    }
  }

  Future<void> _askOutcome() async {
    final l10n = context.l10n;
    final resisted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.sosLeaveConfirmTitle),
        content: Text(l10n.sosLeaveConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.sosGaveIn),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.sosResisted),
          ),
        ],
      ),
    );
    if (resisted != null && mounted) await _resolve(resisted: resisted);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final left = sosDuration - _elapsed;
    final (phase, _) = Breathing.at(_elapsed);
    final phaseText = switch (phase) {
      BreathPhase.inhale => l10n.sosBreathIn,
      BreathPhase.hold => l10n.sosBreathHold,
      BreathPhase.exhale => l10n.sosBreathOut,
    };
    final squad = ref.watch(currentSquadProvider).value;
    final supports = ref.watch(sosSupportsProvider(widget.alertId)).value ?? const [];
    final motivations = ref.watch(myMotivationsProvider).value ?? const [];

    return PopScope(
      canPop: _resolved,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_busy) _askOutcome();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.sosTitle),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _busy ? null : _askOutcome,
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            Text(l10n.sosSubtitle, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            SizedBox(
              height: 240,
              child: Center(
                child: Transform.scale(
                  scale: Breathing.scale(_elapsed),
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.xp.withValues(alpha: 0.55),
                          AppColors.seed.withValues(alpha: 0.25),
                        ],
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      phaseText,
                      style: theme.textTheme.headlineMedium,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              left > Duration.zero
                  ? l10n.sosTimeLeft(formatCountdown(left))
                  : l10n.sosTimeUp,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  squad == null ? Icons.person_outline : Icons.groups,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(squad == null ? l10n.sosNoSquad : l10n.sosSquadNotified),
              ],
            ),
            if (supports.isNotEmpty) ...[
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        l10n.sosSupportsReceived,
                        style: theme.textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        supports.map((s) => s.emoji).join(' '),
                        style: const TextStyle(fontSize: 32),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.sosReasonsTitle, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    if (motivations.isEmpty)
                      Text(l10n.sosNoReasons)
                    else
                      for (final m in motivations)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text('• ${m.text}'),
                        ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ExpansionTile(
                shape: const Border(),
                title: Text(l10n.sosGroundingTitle),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final step in [
                    l10n.sosGrounding5,
                    l10n.sosGrounding4,
                    l10n.sosGrounding3,
                    l10n.sosGrounding2,
                    l10n.sosGrounding1,
                  ])
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(step),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.cravingIntensity(_intensity), style: theme.textTheme.labelLarge),
            Slider(
              value: _intensity.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: '$_intensity',
              onChanged: _busy
                  ? null
                  : (value) => setState(() => _intensity = value.round()),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _busy ? null : () => _resolve(resisted: true),
              child: _busy ? const ButtonSpinner() : Text(l10n.sosResisted),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _busy ? null : () => _resolve(resisted: false),
              child: Text(l10n.sosGaveIn),
            ),
          ],
        ),
      ),
    );
  }
}
