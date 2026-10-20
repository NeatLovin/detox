import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/error_messages.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/button_spinner.dart';
import '../../../../shared/widgets/date_time_picker.dart';
import '../../data/addiction_repository.dart';
import '../../domain/addiction.dart';
import '../../domain/addiction_progress.dart';

/// Opens the relapse sheet. Resolves to true once the relapse is saved.
Future<bool> showRelapseSheet(BuildContext context, Addiction addiction) async {
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => RelapseSheet(addiction: addiction),
  );
  return saved ?? false;
}

class RelapseSheet extends ConsumerStatefulWidget {
  const RelapseSheet({super.key, required this.addiction});

  final Addiction addiction;

  @override
  ConsumerState<RelapseSheet> createState() => _RelapseSheetState();
}

class _RelapseSheetState extends ConsumerState<RelapseSheet> {
  final _noteController = TextEditingController();
  late DateTime _occurredAt = DateTime.now();
  late bool _shared = !widget.addiction.isPrivate;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await pickPastDateTime(
      context,
      initial: _occurredAt,
      first: AddictionProgress.earliestRelapse(
        widget.addiction.streakStartedAt,
        now,
      ),
      last: now,
    );
    if (picked != null) setState(() => _occurredAt = picked);
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final check = AddictionProgress.checkRelapseTime(
      occurredAt: _occurredAt,
      streakStartedAt: widget.addiction.streakStartedAt,
      now: DateTime.now(),
    );
    if (check != RelapseTimeCheck.ok) {
      setState(
        () => _error = check == RelapseTimeCheck.inFuture
            ? l10n.errorRelapseInFuture
            : l10n.errorRelapseBeforeStreak,
      );
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(addictionRepositoryProvider)
          .declareRelapse(
            RelapseInput(
              addictionId: widget.addiction.id,
              occurredAt: _occurredAt,
              note: _noteController.text,
              shared: _shared,
            ),
          );
      if (mounted) Navigator.of(context).pop(true);
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
            Text(
              l10n.relapseSheetTitle(widget.addiction.label),
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(l10n.relapseSheetSubtitle),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule),
              title: Text(l10n.relapseWhen),
              subtitle: Text(formatDateTime(_occurredAt)),
              trailing: const Icon(Icons.edit_calendar_outlined),
              onTap: _busy ? null : _pickDate,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLength: 500,
              maxLines: 3,
              minLines: 1,
              enabled: !_busy,
              decoration: InputDecoration(
                labelText: l10n.relapseNoteLabel,
                hintText: l10n.relapseNoteHint,
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _shared,
              title: Text(l10n.relapseShareToggle),
              subtitle: widget.addiction.isPrivate
                  ? Text(l10n.relapseSharePrivateHint)
                  : null,
              onChanged: _busy
                  ? null
                  : (value) => setState(() => _shared = value),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _busy ? null : _submit,
              child: _busy ? const ButtonSpinner() : Text(l10n.relapseConfirm),
            ),
          ],
        ),
      ),
    );
  }
}
