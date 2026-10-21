import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/numbers.dart';
import '../../../../shared/widgets/date_time_picker.dart';
import '../../domain/addiction.dart';
import '../../domain/addiction_catalog.dart';

/// Editable fields of an addiction. Must be placed inside a [Form]:
/// validation runs through the parent form.
class AddictionDraftForm extends StatefulWidget {
  const AddictionDraftForm({
    super.key,
    required this.draft,
    required this.onChanged,
    this.showQuitDate = true,
  });

  final AddictionDraft draft;
  final ValueChanged<AddictionDraft> onChanged;

  /// The quit date can only be chosen at creation (the streak is server-side).
  final bool showQuitDate;

  @override
  State<AddictionDraftForm> createState() => _AddictionDraftFormState();
}

class _AddictionDraftFormState extends State<AddictionDraftForm> {
  late final _label = TextEditingController(text: widget.draft.label);
  late final _unit = TextEditingController(text: widget.draft.unitLabel);
  late final _cost = TextEditingController(
    text: formatDecimalInput(widget.draft.unitCost),
  );
  late final _baseline = TextEditingController(
    text: formatDecimalInput(widget.draft.baselinePerDay),
  );

  @override
  void dispose() {
    _label.dispose();
    _unit.dispose();
    _cost.dispose();
    _baseline.dispose();
    super.dispose();
  }

  void _emit() {
    widget.onChanged(
      widget.draft.copyWith(
        label: _label.text,
        unitLabel: _unit.text,
        unitCost: parseDecimal(_cost.text) ?? widget.draft.unitCost,
        baselinePerDay:
            parseDecimal(_baseline.text) ?? widget.draft.baselinePerDay,
      ),
    );
  }

  Future<void> _pickQuitDate() async {
    final now = DateTime.now();
    final picked = await pickPastDateTime(
      context,
      initial: widget.draft.quitStartedAt,
      first: DateTime(now.year - 10),
      last: now,
    );
    if (picked != null) {
      widget.onChanged(widget.draft.copyWith(quitStartedAt: picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    String? required(String? value) =>
        (value ?? '').trim().isEmpty ? l10n.commonRequired : null;
    String? decimal(String? value) =>
        parseDecimal(value ?? '') == null ? l10n.commonInvalidNumber : null;
    const gap = SizedBox(height: 12);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.draft.type == AddictionType.alcohol) ...[
          Card(
            color: Colors.orange.withValues(alpha: 0.15),
            child: ListTile(
              leading: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
              title: Text(l10n.alcoholSafetyNote),
            ),
          ),
          const SizedBox(height: 12),
        ],
        TextFormField(
          controller: _label,
          maxLength: 40,
          decoration: InputDecoration(
            labelText: l10n.addictionLabelField,
            counterText: '',
          ),
          validator: required,
          onChanged: (_) => _emit(),
        ),
        gap,
        TextFormField(
          controller: _unit,
          maxLength: 30,
          decoration: InputDecoration(
            labelText: l10n.addictionUnitField,
            counterText: '',
          ),
          validator: required,
          onChanged: (_) => _emit(),
        ),
        gap,
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _cost,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: l10n.addictionUnitCostField,
                ),
                validator: decimal,
                onChanged: (_) => _emit(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _baseline,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: l10n.addictionBaselineField,
                ),
                validator: decimal,
                onChanged: (_) => _emit(),
              ),
            ),
          ],
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: widget.draft.isPrivate,
          title: Text(l10n.addictionPrivateToggle),
          subtitle: Text(l10n.addictionPrivateHint),
          secondary: const Icon(Icons.lock_outline),
          onChanged: (value) =>
              widget.onChanged(widget.draft.copyWith(isPrivate: value)),
        ),
        if (widget.showQuitDate)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event_outlined),
            title: Text(l10n.addictionQuitDateField),
            subtitle: Text(formatDateTime(widget.draft.quitStartedAt)),
            trailing: const Icon(Icons.edit_calendar_outlined),
            onTap: _pickQuitDate,
          ),
        Text(
          l10n.addictionXpPerDay(AddictionCatalog.xpPerDay(widget.draft.type)),
          style: Theme.of(context).textTheme.labelLarge
              ?.copyWith(color: Theme.of(context).colorScheme.tertiary),
        ),
      ],
    );
  }
}
