import 'dart:async';

import 'package:detox/core/l10n/l10n.dart';
import 'package:detox/core/theme/app_theme.dart';
import 'package:detox/core/utils/clock.dart';
import 'package:detox/core/utils/formatters.dart';
import 'package:detox/features/addictions/domain/addiction.dart';
import 'package:detox/features/addictions/presentation/widgets/addiction_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final streakStart = DateTime.utc(2026, 5, 1, 8);

  Addiction addiction({bool isPrivate = false, int bestStreakSeconds = 0}) =>
      Addiction(
        id: 'a1',
        userId: 'u1',
        type: AddictionType.snus,
        label: 'Snus',
        unitLabel: 'sachets',
        unitCost: 0.45,
        baselinePerDay: 10,
        isPrivate: isPrivate,
        quitStartedAt: streakStart,
        streakStartedAt: streakStart,
        bestStreakSeconds: bestStreakSeconds,
        createdAt: streakStart,
      );

  Future<StreamController<DateTime>> pumpCard(
    WidgetTester tester, {
    required Addiction item,
    required DateTime now,
    VoidCallback? onRelapse,
  }) async {
    final ticks = StreamController<DateTime>();
    addTearDown(ticks.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          nowTickerProvider.overrideWith((ref) async* {
            yield now;
            yield* ticks.stream;
          }),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          locale: const Locale('fr'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: SingleChildScrollView(
              child: AddictionCard(
                addiction: item,
                onRelapse: onRelapse ?? () {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    return ticks;
  }

  testWidgets(
    'shows the live timer, savings, avoided units and next milestone',
    (tester) async {
      await pumpCard(
        tester,
        item: addiction(),
        now: streakStart.add(
          const Duration(days: 3, hours: 5, minutes: 7, seconds: 9),
        ),
      );

      expect(find.text('Snus'), findsOneWidget);
      expect(find.text('3j 5h 7m 9s'), findsOneWidget);
      // 3.213 days × 10 × 0.45 CHF ≈ 14.46 CHF, 32 sachets avoided.
      final saved = formatChf(277629 / 86400 * 10 * 0.45);
      expect(saved, startsWith('14'));
      expect(find.text(saved), findsOneWidget);
      expect(find.text('32 sachets'), findsOneWidget);
      expect(find.text('Prochain palier : 7 j'), findsOneWidget);
      expect(find.text('+100 XP'), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsNothing);
    },
  );

  testWidgets('the timer ticks locally every second', (tester) async {
    final ticks = await pumpCard(
      tester,
      item: addiction(),
      now: streakStart.add(const Duration(minutes: 1)),
    );
    expect(find.text('0j 0h 1m 0s'), findsOneWidget);

    ticks.add(streakStart.add(const Duration(minutes: 1, seconds: 1)));
    await tester.pump();
    await tester.pump();
    expect(find.text('0j 0h 1m 1s'), findsOneWidget);
  });

  testWidgets('private addiction shows a lock badge', (tester) async {
    await pumpCard(
      tester,
      item: addiction(isPrivate: true),
      now: streakStart.add(const Duration(hours: 1)),
    );
    expect(find.byIcon(Icons.lock), findsOneWidget);
    expect(find.text('Privée'), findsOneWidget);
  });

  testWidgets('record keeps the best streak', (tester) async {
    await pumpCard(
      tester,
      item: addiction(bestStreakSeconds: 86400 * 12),
      now: streakStart.add(const Duration(days: 2)),
    );
    expect(find.text('12 jours'), findsOneWidget);
  });

  testWidgets('relapse button triggers the callback', (tester) async {
    var tapped = false;
    await pumpCard(
      tester,
      item: addiction(),
      now: streakStart.add(const Duration(hours: 1)),
      onRelapse: () => tapped = true,
    );
    await tester.ensureVisible(find.text("J'ai rechuté"));
    await tester.tap(find.text("J'ai rechuté"));
    expect(tapped, isTrue);
  });
}
