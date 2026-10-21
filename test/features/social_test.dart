import 'dart:io';

import 'package:detox/core/l10n/l10n.dart';
import 'package:detox/features/community/domain/feed_event.dart';
import 'package:detox/features/community/domain/feed_reaction.dart';
import 'package:detox/features/community/domain/leaderboard_week.dart';
import 'package:detox/features/community/presentation/community_screen.dart';
import 'package:detox/features/community/presentation/widgets/feed_tile.dart';
import 'package:detox/features/diagnostics/domain/crash_report.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('fr'));

  group('LeaderboardWeek', () {
    test('starts on Monday midnight', () {
      final wednesday = DateTime(2026, 10, 21, 15, 30);
      expect(LeaderboardWeek.startOf(wednesday), DateTime(2026, 10, 19));
      expect(LeaderboardWeek.endOf(wednesday), DateTime(2026, 10, 26));
    });

    test('Monday and Sunday belong to the same week', () {
      expect(LeaderboardWeek.startOf(DateTime(2026, 10, 19, 0, 0)), DateTime(2026, 10, 19));
      expect(LeaderboardWeek.startOf(DateTime(2026, 10, 25, 23, 59)), DateTime(2026, 10, 19));
    });

    test('crosses months and years', () {
      expect(LeaderboardWeek.startOf(DateTime(2027, 1, 2)), DateTime(2026, 12, 28));
      expect(LeaderboardWeek.endOf(DateTime(2026, 12, 31)), DateTime(2027, 1, 4));
    });

    test('remaining time is shown in days and hours', () {
      expect(
        CommunityScreen.weekLeft(l10n, const Duration(days: 4, hours: 11, minutes: 5)),
        'Nouvelle semaine dans 4 j 11 h',
      );
      expect(CommunityScreen.weekLeft(l10n, const Duration(hours: 5)), 'Nouvelle semaine dans 5 h');
      expect(CommunityScreen.weekLeft(l10n, const Duration(seconds: 20)), 'Nouvelle semaine dans 1 min');
    });
  });

  group('Reactions', () {
    FeedReaction r(String event, String user, String emoji) =>
        FeedReaction(eventId: event, userId: user, emoji: emoji);

    test('are grouped by event with the player\'s own one', () {
      final summary = summarizeReactions([
        r('e1', 'me', '🔥'),
        r('e1', 'bob', '🔥'),
        r('e1', 'ana', '👏'),
        r('e2', 'bob', '❤️'),
      ], 'me');
      expect(summary['e1']!.counts, {'🔥': 2, '👏': 1});
      expect(summary['e1']!.mine, '🔥');
      expect(summary['e2']!.mine, isNull);
      expect(summary['e1']!.ordered.map((e) => e.key), ['👏', '🔥']);
    });

    test('toggle adds, replaces and removes like the server', () {
      const none = ReactionSummary(counts: {'🔥': 1});
      final added = none.toggle('👏');
      expect(added, const ReactionSummary(counts: {'🔥': 1, '👏': 1}, mine: '👏'));
      final replaced = added.toggle('🔥');
      expect(replaced, const ReactionSummary(counts: {'🔥': 2}, mine: '🔥'));
      expect(replaced.toggle('🔥'), none);
      expect(ReactionSummary.empty.toggle('💪').toggle('💪'), ReactionSummary.empty);
    });

    test('a relapse or an SOS only gets support', () {
      expect(allowedReactions(FeedEventType.relapse), ['💪', '❤️']);
      expect(allowedReactions(FeedEventType.sos), ['💪', '❤️']);
      expect(allowedReactions(FeedEventType.milestone), feedReactionEmojis);
    });

    test('emoji list matches the SQL check', () {
      final sql = File('supabase/migrations/20261021140000_social.sql').readAsStringSync();
      final block = RegExp(
        r'-- @rules:feed_reactions:begin(.*?)-- @rules:feed_reactions:end',
        dotAll: true,
      ).firstMatch(sql)!.group(1)!;
      final emojis = [for (final m in RegExp("'([^']+)'").allMatches(block)) m.group(1)!];
      expect(emojis, feedReactionEmojis);
    });
  });

  group('Week winner in the feed', () {
    FeedEvent event(Map<String, dynamic> payload) => FeedEvent.fromJson({
      'id': 'e1',
      'user_id': 'u1',
      'type': 'week_winner',
      'payload': {'username': 'Bob', 'avatar_emoji': '🐻', ...payload},
      'created_at': '2026-10-26T00:10:00Z',
    });

    test('names the winner and the XP', () {
      final e = event({'xp': 420, 'tie': false});
      expect(e.type, FeedEventType.weekWinner);
      expect(FeedTile.textFor(l10n, e), 'Bob remporte la semaine avec 420 XP 🏆');
    });

    test('says when it is a tie', () {
      expect(FeedTile.textFor(l10n, event({'xp': 300, 'tie': true})), contains('ex æquo'));
    });
  });

  group('CrashReportPolicy', () {
    test('bugs are reported', () {
      expect(CrashReportPolicy.shouldReport(StateError('Bad state')), isTrue);
      expect(CrashReportPolicy.shouldReport(const FormatException('bad json')), isTrue);
      expect(
        CrashReportPolicy.shouldReport(PostgrestException(message: 'boom', code: '42P01')),
        isTrue,
      );
    });

    test('offline moments and business answers are not', () {
      expect(CrashReportPolicy.shouldReport(const SocketException('Failed host lookup')), isFalse);
      expect(CrashReportPolicy.shouldReport(Exception('ClientException: Failed host lookup')), isFalse);
      expect(
        CrashReportPolicy.shouldReport(PostgrestException(message: 'own_event', code: 'P0001')),
        isFalse,
      );
      expect(CrashReportPolicy.shouldReport(AuthException('Invalid OTP')), isFalse);
    });

    test('stacks are trimmed to their top', () {
      final stack = StackTrace.fromString(
        List.generate(60, (i) => '#$i frame$i').join('\n'),
      );
      final trimmed = CrashReportPolicy.trimStack(stack)!;
      expect(trimmed.split('\n'), hasLength(CrashReportPolicy.maxStackLines));
      expect(trimmed, startsWith('#0 frame0'));
      expect(CrashReportPolicy.trimStack(null), isNull);
    });

    test('the same error at the same place has the same key', () {
      final stack = StackTrace.fromString('#0 a\n#1 b\n#2 c\n#3 d');
      final a = CrashReportPolicy.build(StateError('x'), stack);
      final b = CrashReportPolicy.build(StateError('x'), StackTrace.fromString('#0 a\n#1 b\n#2 c\n#9 z'));
      final c = CrashReportPolicy.build(StateError('y'), stack);
      expect(a.sessionKey, b.sessionKey);
      expect(a.sessionKey, isNot(c.sessionKey));
    });
  });
}
