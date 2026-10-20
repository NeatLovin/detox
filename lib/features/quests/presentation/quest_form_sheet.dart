import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_messages.dart';
import '../../../core/l10n/l10n.dart';
import '../../../shared/widgets/button_spinner.dart';
import '../data/quest_repository.dart';
import '../domain/quest.dart';
import '../domain/quest_catalog.dart';
import 'quest_providers.dart';

/// Opens the quest form: a new quest when [quest] is null, else edit/archive.
Future<void> showQuestFormSheet(BuildContext context, {DailyQuest? quest}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => QuestFormSheet(quest: quest),
    );

class QuestFormSheet extends ConsumerStatefulWidget {
  const QuestFormSheet({super.key, this.quest});

  final DailyQuest? quest;

  @override
  ConsumerState<QuestFormSheet> createState() => _QuestFormSheetState();
}

class _QuestFormSheetState extends ConsumerState<QuestFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late QuestType _type = widget.quest?.type ?? QuestType.water;
  late final _label = TextEditingController(
    text: widget.quest?.label ?? QuestCatalog.of(QuestType.water).label,
  );
  late final _unit = TextEditingController(
    text: widget.quest?.unitLabel ?? QuestCatalog.of(QuestType.water).unitLabel,
  );
  late final _target = TextEditingController(
    text: formatQuestValue(
      widget.quest?.target ?? QuestCatalog.of(QuestType.water).target,
    ),
  );
  bool _busy = false;
  String? _error;

  bool get _editing => widget.quest != null;

  @override
  void dispose() {
    _label.dispose();
    _unit.dispose();
    _target.dispose();
    super.dispose();
  }

  void _pick(QuestType type) {
    final preset = QuestCatalog.of(type);
    setState(() {
      _type = type;
      _label.text = preset.label;
      _unit.text = preset.unitLabel;
      _target.text = formatQuestValue(preset.target);
    });
  }

  double? _parseTarget() =>
      double.tryParse(_target.text.trim().replaceAll(',', '.'));

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = context.l10n;
    setState(() {
      _busy = true;
      _error = null;
    });
    final draft = QuestDraft(
      type: _type,
      label: _label.text,
      unitLabel: _unit.text,
      target: _parseTarget()!,
    );
    try {
      final repo = ref.read(questRepositoryProvider);
      if (_editing) {
        await repo.update(widget.quest!.id, draft);
      } else {
        await repo.create(draft);
      }
      ref.invalidate(activeQuestsProvider);
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

  Future<void> _archive() async {
    final l10n = context.l10n;
    setState(() => _busy = true);
    try {
      await ref.read(questRepositoryProvider).archive(widget.quest!.id);
      ref.invalidate(activeQuestsProvider);
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
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _editing ? l10n.questFormEditTitle : l10n.questFormNewTitle,
                style: theme.textTheme.titleLarge,
              ),
              if (!_editing) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final preset in QuestCatalog.presets)
                      ChoiceChip(
                        avatar: Text(preset.emoji),
                        label: Text(l10n.questTypeLabel(preset.type.dbValue)),
                        selected: preset.type == _type,
                        onSelected: _busy ? null : (_) => _pick(preset.type),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _label,
                enabled: !_busy,
                maxLength: 40,
                decoration: InputDecoration(labelText: l10n.questLabelField),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.commonRequired : null,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _target,
                      enabled: !_busy,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: l10n.questTargetField,
                      ),
                      validator: (_) {
                        final value = _parseTarget();
                        return value == null || value <= 0 || value > 100000
                            ? l10n.commonInvalidNumber
                            : null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _unit,
                      enabled: !_busy,
                      maxLength: 20,
                      decoration: InputDecoration(labelText: l10n.questUnitField),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? l10n.commonRequired
                          : null,
                    ),
                  ),
                ],
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
                onPressed: _busy ? null : _save,
                child: _busy ? const ButtonSpinner() : Text(l10n.commonSave),
              ),
              if (_editing) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _busy ? null : _archive,
                  icon: const Icon(Icons.archive_outlined),
                  label: Text(l10n.questArchive),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
