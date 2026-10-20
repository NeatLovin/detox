import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_messages.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/session/session_providers.dart';
import '../../../shared/widgets/button_spinner.dart';
import '../../addictions/domain/addiction.dart';
import '../data/craving_repository.dart';
import '../domain/craving.dart';
import 'craving_providers.dart';

/// What happened after the craving sheet closed.
enum CravingSheetResult { resisted, gaveIn }

/// Opens the craving sheet for one of [addictions] (non-empty).
/// Resolves to null when dismissed.
Future<(CravingSheetResult, Addiction)?> showCravingSheet(
  BuildContext context,
  List<Addiction> addictions,
) => showModalBottomSheet<(CravingSheetResult, Addiction)>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => CravingSheet(addictions: addictions),
);

String cravingTriggerText(AppLocalizations l10n, CravingTrigger trigger) =>
    l10n.cravingTriggerLabel(trigger.dbValue);

class CravingSheet extends ConsumerStatefulWidget {
  const CravingSheet({super.key, required this.addictions});

  final List<Addiction> addictions;

  @override
  ConsumerState<CravingSheet> createState() => _CravingSheetState();
}

class _CravingSheetState extends ConsumerState<CravingSheet> {
  final _noteController = TextEditingController();
  late Addiction _addiction = widget.addictions.first;
  int _intensity = 3;
  CravingTrigger _trigger = CravingTrigger.other;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit({required bool resisted}) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final xp = await ref
          .read(cravingRepositoryProvider)
          .log(
            CravingInput(
              addictionId: _addiction.id,
              intensity: _intensity,
              trigger: _trigger,
              resisted: resisted,
              note: _noteController.text,
            ),
          );
      ref.invalidate(recentCravingsProvider);
      ref.invalidate(playerStatsProvider);
      if (resisted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              xp > 0 ? l10n.cravingSavedXp(xp) : l10n.cravingSaved,
            ),
          ),
        );
      }
      if (mounted) {
        Navigator.of(context).pop((
          resisted ? CravingSheetResult.resisted : CravingSheetResult.gaveIn,
          _addiction,
        ));
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = errorMessage(l10n, error);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.cravingSheetTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(l10n.cravingSheetSubtitle),
            if (widget.addictions.length > 1) ...[
              const SizedBox(height: 16),
              Text(l10n.cravingAddictionLabel, style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final addiction in widget.addictions)
                    ChoiceChip(
                      label: Text(addiction.label),
                      selected: addiction.id == _addiction.id,
                      onSelected: _busy
                          ? null
                          : (_) => setState(() => _addiction = addiction),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Text(
              l10n.cravingIntensity(_intensity),
              style: theme.textTheme.labelLarge,
            ),
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
            Text(l10n.cravingTriggerTitle, style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final trigger in CravingTrigger.values)
                  ChoiceChip(
                    avatar: Text(trigger.emoji),
                    label: Text(cravingTriggerText(l10n, trigger)),
                    selected: trigger == _trigger,
                    onSelected: _busy
                        ? null
                        : (_) => setState(() => _trigger = trigger),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              maxLength: 300,
              maxLines: 2,
              minLines: 1,
              enabled: !_busy,
              decoration: InputDecoration(labelText: l10n.cravingNoteLabel),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _busy ? null : () => _submit(resisted: true),
              child: _busy ? const ButtonSpinner() : Text(l10n.cravingResisted),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _busy ? null : () => _submit(resisted: false),
              child: Text(l10n.cravingGaveIn),
            ),
          ],
        ),
      ),
    );
  }
}
