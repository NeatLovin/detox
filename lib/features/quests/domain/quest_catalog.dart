import 'quest.dart';

/// How a quest is filled in from its card.
enum QuestInput {
  /// + / - buttons with a fixed step (water, sport, meditation…).
  stepper,

  /// Free number typed in (sleep hours, steps).
  number,

  /// Done / not done (target 1).
  toggle,
}

class QuestPreset {
  const QuestPreset({
    required this.type,
    required this.emoji,
    required this.label,
    required this.unitLabel,
    required this.target,
    required this.input,
    this.step = 1,
  });

  final QuestType type;
  final String emoji;
  final String label;
  final String unitLabel;
  final double target;
  final QuestInput input;
  final double step;
}

abstract final class QuestCatalog {
  static const presets = <QuestPreset>[
    QuestPreset(
      type: QuestType.water,
      emoji: '💧',
      label: 'Boire de l’eau',
      unitLabel: 'verres',
      target: 8,
      input: QuestInput.stepper,
    ),
    QuestPreset(
      type: QuestType.sport,
      emoji: '🏋️',
      label: 'Sport',
      unitLabel: 'min',
      target: 30,
      input: QuestInput.stepper,
      step: 10,
    ),
    QuestPreset(
      type: QuestType.sleep,
      emoji: '😴',
      label: 'Dormir assez',
      unitLabel: 'h',
      target: 7.5,
      input: QuestInput.number,
    ),
    QuestPreset(
      type: QuestType.steps,
      emoji: '🚶',
      label: 'Marcher',
      unitLabel: 'pas',
      target: 8000,
      input: QuestInput.number,
    ),
    QuestPreset(
      type: QuestType.meditation,
      emoji: '🧘',
      label: 'Méditer',
      unitLabel: 'min',
      target: 10,
      input: QuestInput.stepper,
      step: 5,
    ),
    QuestPreset(
      type: QuestType.reading,
      emoji: '📖',
      label: 'Lire',
      unitLabel: 'min',
      target: 20,
      input: QuestInput.stepper,
      step: 10,
    ),
    QuestPreset(
      type: QuestType.noScreen,
      emoji: '📵',
      label: 'Pas d’écran après 23 h',
      unitLabel: 'fait',
      target: 1,
      input: QuestInput.toggle,
    ),
    QuestPreset(
      type: QuestType.custom,
      emoji: '✨',
      label: '',
      unitLabel: 'fois',
      target: 1,
      input: QuestInput.stepper,
    ),
  ];

  static QuestPreset of(QuestType type) =>
      presets.firstWhere((p) => p.type == type);

  /// Default draft of a preset (used by the onboarding).
  static QuestDraft draftFor(QuestType type, {String customLabel = ''}) {
    final preset = of(type);
    return QuestDraft(
      type: type,
      label: type == QuestType.custom ? customLabel : preset.label,
      unitLabel: preset.unitLabel,
      target: preset.target,
    );
  }

  /// Input mode of a quest: a custom quest with target 1 behaves as a toggle.
  static QuestInput inputFor(DailyQuest quest) {
    final preset = of(quest.type);
    if (quest.type == QuestType.custom && quest.target == 1) {
      return QuestInput.toggle;
    }
    return preset.input;
  }
}

/// Mirrored in SQL: private.on_quest_before_insert (test/sql_parity_test.dart).
abstract final class QuestLimits {
  static const maxActive = 8;
}
