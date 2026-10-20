import 'package:detox/features/quests/domain/quest.dart';
import 'package:detox/features/quests/domain/quest_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every preset draft is valid, except a custom one without a name', () {
    for (final preset in QuestCatalog.presets) {
      final draft = QuestCatalog.draftFor(preset.type);
      expect(draft.isValid, preset.type != QuestType.custom, reason: preset.type.name);
    }
    expect(
      QuestCatalog.draftFor(QuestType.custom, customLabel: 'Prendre l’air').isValid,
      isTrue,
    );
  });

  test('copyWith keeps the type and validates the target like SQL', () {
    final draft = QuestCatalog.draftFor(QuestType.water);
    expect(draft.copyWith(target: 10).target, 10);
    expect(draft.copyWith(target: 10).type, QuestType.water);
    expect(draft.copyWith(target: 0).isValid, isFalse);
    expect(draft.copyWith(target: 100001).isValid, isFalse);
    expect(draft.copyWith(label: '  ').isValid, isFalse);
  });
}
