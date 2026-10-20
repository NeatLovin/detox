import 'package:detox/core/l10n/l10n.dart';
import 'package:detox/features/squad/domain/feed_event.dart';
import 'package:detox/features/squad/presentation/widgets/feed_tile.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('fr'));

  FeedEvent event(String type, Map<String, dynamic> payload) =>
      FeedEvent.fromJson({
        'id': 'e1',
        'squad_id': 's1',
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
      FeedTile.textFor(l10n, event('joined_squad', {})),
      "Bob a rejoint l'escouade",
    );
  });

  test('unknown event types do not crash', () {
    final e = event('boss_raid', {});
    expect(e.type, FeedEventType.unknown);
    expect(FeedTile.textFor(l10n, e), contains('Bob'));
  });
}
