import 'package:detox/core/l10n/l10n.dart';
import 'package:detox/features/community/domain/feed_event.dart';
import 'package:detox/features/community/presentation/widgets/feed_tile.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('fr'));

  FeedEvent event(String type, Map<String, dynamic> payload) =>
      FeedEvent.fromJson({
        'id': 'e1',
        'user_id': 'u1',
        'type': type,
        'payload': {'username': 'Bob', 'avatar_emoji': '🐻', ...payload},
        'created_at': '2026-06-01T10:00:00Z',
      });

  test('shared relapse of a private addiction never shows its label', () {
    final text = FeedTile.textFor(
      l10n,
      event('relapse', {'addiction_label': 'une addiction privée'}),
    );
    expect(text, contains('une addiction privée'));
    expect(text, contains('Envoie-lui de la force 💪'));
  });

  test('milestone, level up, joined', () {
    expect(
      FeedTile.textFor(
        l10n,
        event('milestone', {
          'days': 7,
          'bonus_xp': 100,
          'addiction_label': 'Snus',
        }),
      ),
      'Bob : 7 jours clean (Snus)',
    );
    expect(
      FeedTile.textFor(l10n, event('level_up', {'level': 4})),
      'Bob passe niveau 4',
    );
    expect(
      FeedTile.textFor(l10n, event('joined', {})),
      'Bob a rejoint Detox 👋',
    );
  });

  test('V1 events', () {
    expect(FeedTile.textFor(l10n, event('pledge', {})), contains('Bob'));
    expect(
      FeedTile.textFor(l10n, event('badge', {'badge': 'streak_7'})),
      'Bob débloque le badge « Une semaine »',
    );
    expect(
      FeedTile.textFor(l10n, event('sos', {'addiction_label': 'une addiction privée'})),
      contains('une addiction privée'),
    );
    expect(
      FeedTile.textFor(l10n, event('sos_support', {'emoji': '💪', 'to_username': 'Alice'})),
      'Bob envoie 💪 à Alice',
    );
  });

  test('old squad events read as unknown, not as a crash', () {
    expect(event('joined_squad', {}).type, FeedEventType.unknown);
  });

  test('unknown event types do not crash', () {
    final e = event('boss_raid', {});
    expect(e.type, FeedEventType.unknown);
    expect(FeedTile.textFor(l10n, e), contains('Bob'));
  });
}
