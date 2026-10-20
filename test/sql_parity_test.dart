import 'dart:io';

import 'package:detox/features/addictions/domain/addiction.dart';
import 'package:detox/features/addictions/domain/addiction_catalog.dart';
import 'package:detox/features/gamification/domain/leveling.dart';
import 'package:detox/features/gamification/domain/milestones.dart';
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

  // Same values verified against public.level_for_xp on Postgres.
  test('levelForXp matches the SQL reference values', () {
    const expected = {0: 1, 99: 1, 100: 2, 299: 2, 300: 3, 1000: 5, 10000: 14};
    expected.forEach((xp, level) {
      expect(levelForXp(xp), level, reason: 'xp=$xp');
    });
  });
}
