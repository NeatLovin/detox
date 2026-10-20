import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../domain/quest.dart';
import '../../domain/quest_catalog.dart';

/// Editable quest draft in the onboarding: daily target, plus the name and
/// unit for a custom quest. Validated by the enclosing Form.
class QuestDraftTile extends StatefulWidget {
  const QuestDraftTile({
    super.key,
    required this.draft,
    required this.onChanged,
    required this.onRemove,
  });

  final QuestDraft draft;
  final ValueChanged<QuestDraft> onChanged;
  final VoidCallback onRemove;

  @override
  State<QuestDraftTile> createState() => _QuestDraftTileState();
}

class _QuestDraftTileState extends State<QuestDraftTile> {
  late final _label = TextEditingController(text: widget.draft.label);
  late final _unit = TextEditingController(text: widget.draft.unitLabel);
  late final _target = TextEditingController(
    text: formatQuestValue(widget.draft.target),
  );

  bool get _isCustom => widget.draft.type == QuestType.custom;

  @override
  void dispose() {
    _label.dispose();
    _unit.dispose();
    _target.dispose();
    super.dispose();
  }

  double? _parse(String text) => double.tryParse(text.trim().replaceAll(',', '.'));

  void _emit() {
    widget.onChanged(
      widget.draft.copyWith(
        label: _label.text,
        unitLabel: _unit.text,
        target: _parse(_target.text) ?? 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final preset = QuestCatalog.of(widget.draft.type);
    final toggle = preset.input == QuestInput.toggle;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(preset.emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isCustom
                        ? l10n.questTypeLabel(widget.draft.type.dbValue)
                        : widget.draft.label,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: l10n.commonDelete,
                  onPressed: widget.onRemove,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            if (_isCustom) ...[
              TextFormField(
                controller: _label,
                maxLength: 40,
                decoration: InputDecoration(
                  labelText: l10n.questLabelField,
                  hintText: l10n.onboardingCustomQuestHint,
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.commonRequired : null,
                onChanged: (_) => _emit(),
              ),
              const SizedBox(height: 8),
            ],
            if (toggle)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(l10n.onboardingQuestToggleHint),
              )
            else
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _target,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: l10n.questTargetField,
                          suffixText: _isCustom ? null : widget.draft.unitLabel,
                        ),
                        validator: (v) {
                          final value = _parse(v ?? '');
                          return value == null || value <= 0 || value > 100000
                              ? l10n.commonInvalidNumber
                              : null;
                        },
                        onChanged: (_) => _emit(),
                      ),
                    ),
                    if (_isCustom) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _unit,
                          maxLength: 20,
                          decoration: InputDecoration(
                            labelText: l10n.questUnitField,
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? l10n.commonRequired
                              : null,
                          onChanged: (_) => _emit(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
