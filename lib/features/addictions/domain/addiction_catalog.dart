import 'addiction.dart';

/// Default values proposed during onboarding. Everything except [xpPerDay]
/// is editable by the user. [xpPerDay] is duplicated in SQL
/// (private.addiction_xp_rules) — test/sql_parity_test.dart keeps them in sync.
class AddictionPreset {
  const AddictionPreset({
    required this.type,
    required this.emoji,
    required this.label,
    required this.unitLabel,
    required this.unitCost,
    required this.baselinePerDay,
    required this.xpPerDay,
  });

  final AddictionType type;
  final String emoji;
  final String label;
  final String unitLabel;
  final double unitCost;
  final double baselinePerDay;
  final int xpPerDay;
}

abstract final class AddictionCatalog {
  static const presets = <AddictionPreset>[
    AddictionPreset(
      type: AddictionType.porn,
      emoji: '🔞',
      label: 'Porno',
      unitLabel: 'sessions',
      unitCost: 0,
      baselinePerDay: 1,
      xpPerDay: 30,
    ),
    AddictionPreset(
      type: AddictionType.snus,
      emoji: '🫙',
      label: 'Snus',
      unitLabel: 'sachets',
      unitCost: 0.45,
      baselinePerDay: 10,
      xpPerDay: 30,
    ),
    AddictionPreset(
      type: AddictionType.cigarette,
      emoji: '🚬',
      label: 'Cigarette',
      unitLabel: 'cigarettes',
      unitCost: 0.45,
      baselinePerDay: 10,
      xpPerDay: 30,
    ),
    AddictionPreset(
      type: AddictionType.vape,
      emoji: '💨',
      label: 'Vape',
      unitLabel: 'sessions',
      unitCost: 0.30,
      baselinePerDay: 10,
      xpPerDay: 25,
    ),
    AddictionPreset(
      type: AddictionType.weed,
      emoji: '🌿',
      label: 'Beuh',
      unitLabel: 'joints',
      unitCost: 10,
      baselinePerDay: 1,
      xpPerDay: 25,
    ),
    AddictionPreset(
      type: AddictionType.alcohol,
      emoji: '🍺',
      label: 'Alcool',
      unitLabel: 'verres',
      unitCost: 6,
      baselinePerDay: 2,
      xpPerDay: 25,
    ),
    AddictionPreset(
      type: AddictionType.sugar,
      emoji: '🍬',
      label: 'Sucre',
      unitLabel: 'portions',
      unitCost: 2,
      baselinePerDay: 2,
      xpPerDay: 15,
    ),
    AddictionPreset(
      type: AddictionType.custom,
      emoji: '✨',
      label: '',
      unitLabel: '',
      unitCost: 0,
      baselinePerDay: 1,
      xpPerDay: 20,
    ),
  ];

  static AddictionPreset of(AddictionType type) =>
      presets.firstWhere((p) => p.type == type);

  static int xpPerDay(AddictionType type) => of(type).xpPerDay;

  static AddictionDraft draftFor(AddictionType type, {DateTime? now}) {
    final preset = of(type);
    return AddictionDraft(
      type: type,
      label: preset.label,
      unitLabel: preset.unitLabel,
      unitCost: preset.unitCost,
      baselinePerDay: preset.baselinePerDay,
      quitStartedAt: now ?? DateTime.now(),
    );
  }
}
