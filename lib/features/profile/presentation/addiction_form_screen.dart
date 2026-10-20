import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_messages.dart';
import '../../../core/l10n/l10n.dart';
import '../../../shared/widgets/button_spinner.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../addictions/data/addiction_repository.dart';
import '../../addictions/domain/addiction.dart';
import '../../addictions/domain/addiction_catalog.dart';
import '../../addictions/domain/addiction_limits.dart';
import '../../addictions/domain/addiction_progress.dart';
import '../../addictions/presentation/addiction_providers.dart';
import '../../addictions/presentation/widgets/addiction_draft_form.dart';
import '../../addictions/presentation/widgets/addiction_type_label.dart';

/// Adds a new addiction, or edits one when [addictionId] is set.
class AddictionFormScreen extends ConsumerWidget {
  const AddictionFormScreen({super.key, this.addictionId});

  final String? addictionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = addictionId;
    if (id == null) return const _AddictionForm();

    final l10n = context.l10n;
    final addictions = ref.watch(myAddictionsProvider);
    return addictions.when(
      data: (all) {
        final existing = all.where((a) => a.id == id).firstOrNull;
        if (existing == null) {
          return Scaffold(
            appBar: AppBar(),
            body: EmptyState(emoji: '🤷', message: l10n.errorGeneric),
          );
        }
        return _AddictionForm(existing: existing);
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: ErrorState(
          error: error,
          onRetry: () => ref.invalidate(myAddictionsProvider),
        ),
      ),
    );
  }
}

class _AddictionForm extends ConsumerStatefulWidget {
  const _AddictionForm({this.existing});

  final Addiction? existing;

  @override
  ConsumerState<_AddictionForm> createState() => _AddictionFormState();
}

class _AddictionFormState extends ConsumerState<_AddictionForm> {
  final _formKey = GlobalKey<FormState>();
  late AddictionDraft _draft = _initialDraft();
  bool _busy = false;
  String? _error;

  bool get _isEdit => widget.existing != null;

  AddictionDraft _initialDraft() {
    final existing = widget.existing;
    if (existing == null) return AddictionCatalog.draftFor(AddictionType.snus);
    return AddictionDraft(
      type: existing.type,
      label: existing.label,
      unitLabel: existing.unitLabel,
      unitCost: existing.unitCost,
      baselinePerDay: existing.baselinePerDay,
      isPrivate: existing.isPrivate,
      quitStartedAt: existing.quitStartedAt,
    );
  }

  /// Types of the user's active addictions (for the anti-farming cap).
  List<AddictionType> get _activeTypes => AddictionLimits.activeTypes(
    ref.read(myAddictionsProvider).value ?? const [],
  ).toList();

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = context.l10n;
    if (!_isEdit && !AddictionLimits.canAdd(_activeTypes, _draft.type)) {
      setState(() => _error = l10n.errorTooManyAddictions);
      return;
    }
    if (!_isEdit &&
        !AddictionProgress.isValidQuitDate(
          _draft.quitStartedAt,
          DateTime.now(),
        )) {
      setState(() => _error = l10n.errorQuitDateInFuture);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final repository = ref.read(addictionRepositoryProvider);
      final existing = widget.existing;
      if (existing == null) {
        await repository.create(_draft);
      } else {
        await repository.update(existing.id, _draft);
      }
      ref.invalidate(myAddictionsProvider);
      if (mounted) Navigator.of(context).pop();
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
    final activeTypes = AddictionLimits.activeTypes(
      ref.watch(myAddictionsProvider).value ?? const [],
    ).toList();
    final atLimit = !_isEdit && !AddictionLimits.canAddAny(activeTypes);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEdit ? l10n.addictionFormEditTitle : l10n.addictionFormNewTitle,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            if (!_isEdit) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final preset in AddictionCatalog.presets)
                    ChoiceChip(
                      avatar: Text(preset.emoji),
                      label: Text(addictionTypeLabel(l10n, preset.type)),
                      selected: _draft.type == preset.type,
                      onSelected:
                          AddictionLimits.canAdd(activeTypes, preset.type)
                          ? (_) => setState(
                              () => _draft = AddictionCatalog.draftFor(
                                preset.type,
                              ),
                            )
                          : null,
                    ),
                ],
              ),
              const SizedBox(height: 24),
            ],
            AddictionDraftForm(
              // Rebuild the fields when the preset changes.
              key: ValueKey(_draft.type),
              draft: _draft,
              showQuitDate: !_isEdit,
              onChanged: (draft) => setState(() => _draft = draft),
            ),
            if (atLimit) ...[
              const SizedBox(height: 16),
              Text(
                l10n.errorTooManyAddictions,
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _busy || atLimit ? null : _save,
              child: _busy ? const ButtonSpinner() : Text(l10n.commonSave),
            ),
          ],
        ),
      ),
    );
  }
}
