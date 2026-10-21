import 'dart:convert';
import 'dart:io';

import 'package:detox/features/addictions/domain/addiction.dart';
import 'package:detox/features/health_timeline/domain/health_timeline.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final json = jsonDecode(File('assets/content/health_timeline_fr.json').readAsStringSync())
      as Map<String, dynamic>;
  final timelines = HealthTimelines.fromJson(json);

  test('every addiction type has a timeline', () {
    for (final type in AddictionType.values) {
      expect(timelines.byType[type], isNotNull, reason: type.name);
      expect(timelines.byType[type]!.milestones, isNotEmpty, reason: type.name);
    }
    expect(timelines.disclaimer, isNotEmpty);
  });

  test('milestones are sorted, unique in time and filled in', () {
    for (final entry in timelines.byType.entries) {
      final ms = entry.value.milestones;
      for (var i = 1; i < ms.length; i++) {
        expect(ms[i].after > ms[i - 1].after, isTrue, reason: '${entry.key} #$i');
      }
      for (final m in ms) {
        expect(m.title.trim(), isNotEmpty);
        expect(m.body.trim(), isNotEmpty);
        expect(m.emoji.trim(), isNotEmpty);
      }
    }
  });

  test('body timelines cite a source; progress ones make no medical claim', () {
    for (final entry in timelines.byType.entries) {
      final t = entry.value;
      if (t.kind == TimelineKind.body) {
        expect(t.source, isNotNull, reason: entry.key.name);
        expect(t.sourceUrl, startsWith('https://'), reason: entry.key.name);
      }
    }
    expect(timelines.byType[AddictionType.porn]!.kind, TimelineKind.progress);
    expect(timelines.byType[AddictionType.sugar]!.kind, TimelineKind.progress);
  });

  test('alcohol shows the withdrawal safety warning', () {
    expect(timelines.byType[AddictionType.alcohol]!.warning, contains('médecin'));
  });

  group('progress through a timeline', () {
    final t = timelines.byType[AddictionType.cigarette]!;

    test('nothing reached at the start, first milestone next', () {
      expect(t.latest(Duration.zero), isNull);
      expect(t.next(Duration.zero), same(t.milestones.first));
      expect(t.progressToNext(Duration.zero), 0);
    });

    test('20 min and 8 h milestones of the NHS timeline', () {
      expect(t.milestones.first.after, const Duration(minutes: 20));
      expect(t.reached(const Duration(hours: 9)).length, 2);
      expect(t.next(const Duration(hours: 9))!.after, const Duration(days: 1));
    });

    test('progress between two milestones', () {
      // Halfway between 8 h and 24 h.
      expect(t.progressToNext(const Duration(hours: 16)), closeTo(0.5, 1e-9));
    });

    test('everything reached', () {
      const forever = Duration(days: 365 * 20);
      expect(t.next(forever), isNull);
      expect(t.progressToNext(forever), 1);
      expect(t.latest(forever), same(t.milestones.last));
    });
  });
}
