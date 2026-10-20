import 'dart:io';

import 'package:detox/features/addictions/domain/addiction.dart';
import 'package:detox/features/addictions/domain/addiction_catalog.dart';
import 'package:detox/features/addictions/domain/addiction_limits.dart';
import 'package:detox/features/gamification/domain/leveling.dart';
import 'package:detox/features/gamification/domain/badges.dart';
import 'package:detox/features/gamification/domain/milestones.dart';
import 'package:detox/features/gamification/domain/rewards.dart';
import 'package:detox/features/cravings/domain/craving.dart';
import 'package:detox/features/profile/data/motivation_repository.dart';
import 'package:detox/features/quests/domain/quest.dart';
import 'package:detox/features/quests/domain/quest_catalog.dart';
import 'package:detox/features/sos/domain/sos.dart';
import 'package:flutter_test/flutter_test.dart';

/// Returns the content of the latest `-- @rules:<name>:begin … end` block
/// across all migrations (a later migration overrides an earlier one).
String latestRulesBlock(String name) {
  final files =
      Directory('supabase/migrations')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.sql'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  final pattern = RegExp(
    '-- @rules:$name:begin(.*?)-- @rules:$name:end',
    dotAll: true,
  );
  String? block;
  for (final file in files) {
    for (final match in pattern.allMatches(file.readAsStringSync())) {
      block = match.group(1);
    }
  }
  if (block == null) fail('No @rules:$name block found in migrations');
  return block;
}

void main() {
  test('XP per clean day: Dart catalog == SQL addiction_xp_rules', () {
    final block = latestRulesBlock('xp_per_day');
    final sql = {
      for (final m in RegExp(r"\('(\w+)',\s*(\d+)\)").allMatches(block))
        m.group(1)!: int.parse(m.group(2)!),
    };
    final dart = {
      for (final type in AddictionType.values)
        type.dbValue: AddictionCatalog.xpPerDay(type),
    };
    expect(sql, dart);
  });

  test('Milestones: Dart == SQL private.milestones', () {
    final block = latestRulesBlock('milestones');
    final sql = [
      for (final m in RegExp(r'\((\d+),\s*(\d+)\)').allMatches(block))
        Milestone(int.parse(m.group(1)!), int.parse(m.group(2)!)),
    ];
    expect(sql, Milestones.all);
  });

  test('Every addiction type has a preset', () {
    for (final type in AddictionType.values) {
      expect(AddictionCatalog.of(type).type, type);
    }
  });

  test('SQL CHECK on addictions.type matches the Dart enum', () {
    final schema = File('supabase/migrations/20261020090000_schema.sql')
        .readAsStringSync();
    final check = RegExp(r'type text not null check \(type in \(([^)]*)\)\)')
        .firstMatch(schema)!
        .group(1)!;
    final sqlTypes = RegExp(r"'(\w+)'")
        .allMatches(check)
        .map((m) => m.group(1))
        .toSet();
    expect(sqlTypes, AddictionType.values.map((t) => t.dbValue).toSet());
  });

  test('Addiction cap: Dart == SQL on_addiction_cap_before_insert', () {
    final sql = File('supabase/migrations/20261020100000_anticheat.sql')
        .readAsStringSync();
    final active = RegExp(r'v_active >= (\d+)').firstMatch(sql)!.group(1);
    final custom = RegExp(r'v_custom >= (\d+)').firstMatch(sql)!.group(1);
    expect(int.parse(active!), AddictionLimits.maxActive);
    expect(int.parse(custom!), AddictionLimits.maxCustom);
  });

  // Same values verified against public.level_for_xp on Postgres.
  test('levelForXp matches the SQL reference values', () {
    const expected = {0: 1, 99: 1, 100: 2, 299: 2, 300: 3, 1000: 5, 10000: 14};
    expected.forEach((xp, level) {
      expect(levelForXp(xp), level, reason: 'xp=$xp');
    });
  });

  group('V1 parity (migration 20261020120000_v1.sql)', () {
    final v1 = File('supabase/migrations/20261020120000_v1.sql').readAsStringSync();

    Set<String> checkValues(String column) {
      final match = RegExp(
        '$column text not null(?: default [^ ]+)? check \\($column in \\(([^)]*)\\)',
        dotAll: true,
      ).firstMatch(v1);
      expect(match, isNotNull, reason: 'CHECK on $column not found');
      return RegExp(r"'([^']+)'").allMatches(match!.group(1)!).map((m) => m.group(1)!).toSet();
    }

    test('Rewards: Dart == SQL private.reward_rules', () {
      final block = latestRulesBlock('rewards');
      final sql = [
        for (final m in RegExp(r"\('(\w+)',\s*'(\w+)',\s*(\d+),\s*(\d+)\)").allMatches(block))
          RewardRule(
            key: m.group(1)!,
            reason: m.group(2)!,
            xp: int.parse(m.group(3)!),
            dailyCap: int.parse(m.group(4)!),
          ),
      ];
      expect(sql, Rewards.all);
      expect(v1, contains('v_active >= ${Rewards.minQuestsForAllDoneBonus} and'));
    });

    test('Badge keys == SQL CHECK', () {
      expect(checkValues('key'), BadgeKey.values.map((b) => b.dbValue).toSet());
    });

    test('Quest types == SQL CHECK', () {
      expect(checkValues('type'), QuestType.values.map((t) => t.dbValue).toSet());
    });

    test('Craving triggers == SQL CHECK', () {
      expect(checkValues('trigger'), CravingTrigger.values.map((t) => t.dbValue).toSet());
    });

    test('SOS emojis == SQL CHECK', () {
      expect(checkValues('emoji'), sosSupportEmojis.toSet());
    });

    test('Caps: quests and motivations', () {
      expect(v1, contains('if v_active >= ${QuestLimits.maxActive} then'));
      expect(v1, contains('where user_id = new.user_id) >= $maxMotivations then'));
    });
  });
}
