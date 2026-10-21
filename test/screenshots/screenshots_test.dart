// README screenshots, rendered from the real screens with demo data.
//
// Skipped by a plain `flutter test`. The `Screenshots` workflow runs it with
//   --dart-define=SCREENSHOTS_DIR=<out> --dart-define=FONTS_DIR=<fonts>
// where FONTS_DIR holds Roboto-*.ttf, MaterialIcons-Regular.otf and
// NotoColorEmoji.ttf (the test renderer has no system fonts).
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:detox/core/l10n/l10n.dart';
import 'package:detox/core/router/app_router.dart';
import 'package:detox/core/router/routes.dart';
import 'package:detox/core/theme/app_theme.dart';
import 'package:detox/core/utils/clock.dart';
import 'package:detox/features/addictions/data/addiction_repository.dart';
import 'package:detox/features/addictions/domain/addiction.dart';
import 'package:detox/features/auth/data/auth_repository.dart';
import 'package:detox/features/community/data/community_repository.dart';
import 'package:detox/features/community/domain/feed_event.dart';
import 'package:detox/features/community/domain/leaderboard.dart';
import 'package:detox/features/community/domain/player_profile.dart';
import 'package:detox/features/cravings/data/craving_repository.dart';
import 'package:detox/features/cravings/domain/craving.dart';
import 'package:detox/features/gamification/data/engagement_repository.dart';
import 'package:detox/features/gamification/data/player_stats_repository.dart';
import 'package:detox/features/gamification/domain/badges.dart';
import 'package:detox/features/gamification/domain/player_stats.dart';
import 'package:detox/features/health/data/health_repository.dart';
import 'package:detox/features/health/presentation/health_providers.dart';
import 'package:detox/features/health_timeline/data/health_timeline_providers.dart';
import 'package:detox/features/health_timeline/domain/health_timeline.dart';
import 'package:detox/features/notifications/presentation/push_service.dart';
import 'package:detox/features/profile/data/motivation_repository.dart';
import 'package:detox/features/profile/data/profile_repository.dart';
import 'package:detox/features/profile/domain/profile.dart';
import 'package:detox/features/quests/data/quest_repository.dart';
import 'package:detox/features/quests/domain/quest.dart';
import 'package:detox/features/settings/data/settings_repository.dart';
import 'package:detox/features/sos/data/sos_repository.dart';
import 'package:detox/features/sos/domain/sos.dart';
import 'package:detox/features/stats/data/stats_repository.dart';
import 'package:detox/features/stats/domain/stats.dart';
import 'package:detox/features/updates/data/update_repository.dart';
import 'package:detox/features/updates/domain/app_release.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

const _outDir = String.fromEnvironment('SCREENSHOTS_DIR');
const _fontsDir = String.fromEnvironment('FONTS_DIR');

/// A common Android phone: 1080 × 2400 px.
const _pixelRatio = 2.625;
const _physicalSize = Size(1080, 2400);

const _emojiFont = 'NotoColorEmoji';
final _shotKey = GlobalKey();

// Demo world ---------------------------------------------------------------------

final _now = DateTime.now();
DateTime _ago({int days = 0, int hours = 0}) =>
    _now.subtract(Duration(days: days, hours: hours));
DateTime _today() => DateTime(_now.year, _now.month, _now.day);

const _me = 'me';
const _sarah = 'u-sarah';

final _profile = Profile(
  id: _me,
  username: 'NeatLovin',
  avatarEmoji: '🦁',
  createdAt: _ago(days: 40),
);

Addiction _addiction(
  String id,
  AddictionType type,
  String label,
  String unit, {
  required double cost,
  required double perDay,
  required DateTime since,
  String userId = _me,
  int best = 0,
}) => Addiction(
  id: id,
  userId: userId,
  type: type,
  label: label,
  unitLabel: unit,
  unitCost: cost,
  baselinePerDay: perDay,
  quitStartedAt: since,
  streakStartedAt: since,
  bestStreakSeconds: best,
  createdAt: since,
);

final _myAddictions = [
  _addiction('a-snus', AddictionType.snus, 'Snus', 'sachets',
      cost: 0.45, perDay: 14, since: _ago(days: 12, hours: 5)),
  _addiction('a-vape', AddictionType.vape, 'Puff', 'puffs',
      cost: 0.6, perDay: 10, since: _ago(days: 31, hours: 2)),
  _addiction('a-sugar', AddictionType.sugar, 'Sucre', 'portions',
      cost: 2, perDay: 2, since: _ago(days: 4, hours: 9), best: 9 * 86400),
];

LeaderboardEntry _entry(int rank, String id, String name, String emoji, int level, int xp,
        {bool isPrivate = false}) =>
    LeaderboardEntry(
      rank: rank,
      userId: id,
      username: name,
      avatarEmoji: emoji,
      level: level,
      xp: xp,
      isPrivate: isPrivate,
    );

final _leaderboard = [
  _entry(1, _sarah, 'Sarah_fit', '🦊', 12, 5120),
  _entry(2, 'u-max', 'Maxou', '🐺', 9, 3480),
  _entry(3, _me, 'NeatLovin', '🦁', 7, 2340),
  _entry(4, 'u-yanis', 'Yanis', '🐻', 6, 1915),
  _entry(5, 'u-lina', 'Lina', '🐼', 5, 1460, isPrivate: true),
  _entry(6, 'u-tom', 'Tom', '🐯', 4, 1105),
  _entry(7, 'u-jules', 'Jules', '🐸', 3, 720),
  _entry(8, 'u-ines', 'Inès', '🦄', 2, 310),
];

FeedEvent _event(int i, String userId, FeedEventType type, Map<String, dynamic> payload,
    DateTime at) {
  final who = _leaderboard.firstWhere((e) => e.userId == userId);
  return FeedEvent(
    id: 'f$i',
    userId: userId,
    type: type,
    payload: {'username': who.username, 'avatar_emoji': who.avatarEmoji, ...payload},
    createdAt: at,
  );
}

final _feed = [
  _event(1, 'u-max', FeedEventType.sosSupport, {'emoji': '💪', 'to_username': 'Yanis'},
      _now.subtract(const Duration(minutes: 4))),
  _event(2, _sarah, FeedEventType.milestone,
      {'addiction_label': 'Clope', 'days': 60, 'bonus_xp': 300}, _ago(hours: 1)),
  _event(3, _me, FeedEventType.questsAllDone, {}, _ago(hours: 2)),
  _event(4, 'u-tom', FeedEventType.levelUp, {'level': 4}, _ago(hours: 3)),
  _event(5, 'u-jules', FeedEventType.badge, {'badge': 'first_resist'}, _ago(hours: 5)),
  _event(6, 'u-yanis', FeedEventType.pledge, {}, _ago(hours: 7)),
  _event(7, 'u-ines', FeedEventType.joined, {}, _ago(days: 1)),
];

final _sarahProfile = PlayerProfile(
  userId: _sarah,
  username: 'Sarah_fit',
  avatarEmoji: '🦊',
  isPrivate: false,
  joinedAt: _ago(days: 75),
  level: 12,
  xp: 5120,
  hp: 100,
  rank: 1,
  badges: [
    for (final key in [
      BadgeKey.firstPledge,
      BadgeKey.pledgeStreak7,
      BadgeKey.firstResist,
      BadgeKey.resist10,
      BadgeKey.helper,
      BadgeKey.streak7,
      BadgeKey.streak30,
      BadgeKey.questStreak7,
      BadgeKey.level5,
      BadgeKey.level10,
    ])
      UnlockedBadge(key: key, unlockedAt: _ago(days: 10)),
  ],
  addictions: [
    _addiction('s-cig', AddictionType.cigarette, 'Clope', 'cigarettes',
        cost: 0.5, perDay: 15, since: _ago(days: 60, hours: 3), userId: _sarah),
    _addiction('s-alc', AddictionType.alcohol, 'Alcool', 'verres',
        cost: 6, perDay: 2, since: _ago(days: 21, hours: 8), userId: _sarah),
  ],
);

DailyQuest _quest(String id, QuestType type, String label, String unit, double target) =>
    DailyQuest(
      id: id,
      type: type,
      label: label,
      unitLabel: unit,
      target: target,
      createdAt: _ago(days: 30),
    );

final _quests = [
  _quest('q-water', QuestType.water, 'Boire de l’eau', 'verres', 8),
  _quest('q-sport', QuestType.sport, 'Sport', 'min', 30),
  _quest('q-sleep', QuestType.sleep, 'Dormir', 'h', 7.5),
  _quest('q-steps', QuestType.steps, 'Marcher', 'pas', 10000),
  _quest('q-read', QuestType.reading, 'Lire', 'min', 20),
];

List<QuestLog> _questLogs() {
  final today = _today();
  QuestLog log(String quest, int daysAgo, double value, bool done) => QuestLog(
    questId: quest,
    day: today.subtract(Duration(days: daysAgo)),
    value: value,
    done: done,
    xpAwarded: done,
  );
  return [
    log('q-water', 0, 6, false),
    log('q-sport', 0, 30, true),
    log('q-sleep', 0, 7.5, true),
    log('q-steps', 0, 7420, false),
    for (var d = 1; d <= 6; d++) log('q-sport', d, 30, true),
    for (var d = 1; d <= 11; d++) log('q-sleep', d, 8, true),
    for (var d = 1; d <= 3; d++) log('q-water', d, 8, true),
  ];
}

final _sosAlert = SosAlert(
  id: 'sos-me',
  userId: _me,
  addictionId: 'a-snus',
  addictionLabel: 'Snus',
  createdAt: _now.subtract(const Duration(minutes: 1, seconds: 40)),
);

final _sosSupports = [
  for (final (user, emoji, secs) in [
    ('u-max', '💪', 70),
    (_sarah, '🔥', 55),
    ('u-yanis', '🫂', 30),
    ('u-tom', '🏆', 12),
  ])
    SosSupport(
      alertId: _sosAlert.id,
      userId: user,
      emoji: emoji,
      createdAt: _now.subtract(Duration(seconds: secs)),
    ),
];

// Fake repositories (only what the screens read; the rest throws) -------------------

class _FakeAuth implements AuthRepository {
  @override
  String? get currentUserId => _me;
  @override
  String? get currentEmail => 'neatlovin@example.com';
  @override
  Stream<String?> watchUserId() => Stream.value(_me);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeProfiles implements ProfileRepository {
  @override
  Future<Profile?> fetchProfile(String userId) async => _profile;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeStats implements PlayerStatsRepository {
  @override
  Stream<PlayerStats> watch(String userId) =>
      Stream.value(PlayerStats(userId: userId, xp: 2340, level: 7, hp: 85));
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAddictions implements AddictionRepository {
  @override
  Future<List<Addiction>> fetchMine() async => _myAddictions;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCommunity implements CommunityRepository {
  @override
  Future<List<LeaderboardEntry>> fetchLeaderboard() async => _leaderboard;
  @override
  Future<PlayerProfile> fetchPlayer(String userId) async => _sarahProfile;
  @override
  Stream<List<FeedEvent>> watchFeed({int limit = 50}) => Stream.value(_feed);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeQuests implements QuestRepository {
  @override
  Future<List<DailyQuest>> fetchMine() async => _quests;
  @override
  Future<List<QuestLog>> fetchLogsSince(DateTime since) async => _questLogs();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSos implements SosRepository {
  _FakeSos({required this.withCommunityAlert});

  /// Home shows a friend's SOS; the SOS screen shows the player's own one.
  final bool withCommunityAlert;

  @override
  Stream<List<SosAlert>> watchAlerts() => Stream.value([
    if (withCommunityAlert)
      SosAlert(
        id: 'sos-yanis',
        userId: 'u-yanis',
        addictionLabel: 'Clope',
        createdAt: _now.subtract(const Duration(minutes: 3)),
      ),
  ]);
  @override
  Stream<List<SosSupport>> watchSupports(String alertId) => Stream.value(
    alertId == _sosAlert.id ? _sosSupports : const <SosSupport>[],
  );
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeEngagement implements EngagementRepository {
  @override
  Future<bool> hasPledgedOn(DateTime day) async => true;
  @override
  Future<List<UnlockedBadge>> fetchBadges(String userId) async => [
    for (final key in [
      BadgeKey.firstPledge,
      BadgeKey.firstResist,
      BadgeKey.sosFirst,
      BadgeKey.streak7,
      BadgeKey.streak30,
      BadgeKey.level5,
    ])
      UnlockedBadge(key: key, unlockedAt: _ago(days: 5)),
  ];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeMotivations implements MotivationRepository {
  @override
  Future<List<Motivation>> fetchMine() async => const [
    Motivation(id: 'm1', text: 'Retrouver mon souffle au foot'),
    Motivation(id: 'm2', text: 'Économiser pour le voyage au Japon'),
    Motivation(id: 'm3', text: 'Être fier de moi'),
  ];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCravings implements CravingRepository {
  @override
  Future<List<Craving>> fetchRecent({int limit = 50}) async => const [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUpdates implements UpdateRepository {
  @override
  Future<AppRelease?> fetchLatest() async => null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSettings implements SettingsRepository {
  @override
  Future<String?> fetchTwintPhone() async => null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeXp implements StatsRepository {
  @override
  Future<List<XpEntry>> fetchXpSince(DateTime since) async => const [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Harness --------------------------------------------------------------------------

Future<void> _loadFont(String family, Iterable<File> files) async {
  final loader = FontLoader(family);
  for (final file in files) {
    final bytes = file.readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

ThemeData _themeWithEmoji() {
  final theme = AppTheme.dark();
  return theme.copyWith(
    textTheme: theme.textTheme.apply(fontFamilyFallback: const [_emojiFont]),
    primaryTextTheme: theme.primaryTextTheme.apply(
      fontFamilyFallback: const [_emojiFont],
    ),
  );
}

late HealthTimelines _timelines;

Future<void> _shoot(
  WidgetTester tester, {
  required String name,
  required String route,
  bool communityAlert = false,
}) async {
  tester.view.physicalSize = _physicalSize;
  tester.view.devicePixelRatio = _pixelRatio;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(_FakeAuth()),
      profileRepositoryProvider.overrideWithValue(_FakeProfiles()),
      playerStatsRepositoryProvider.overrideWithValue(_FakeStats()),
      addictionRepositoryProvider.overrideWithValue(_FakeAddictions()),
      communityRepositoryProvider.overrideWithValue(_FakeCommunity()),
      questRepositoryProvider.overrideWithValue(_FakeQuests()),
      sosRepositoryProvider.overrideWithValue(
        _FakeSos(withCommunityAlert: communityAlert),
      ),
      engagementRepositoryProvider.overrideWithValue(_FakeEngagement()),
      motivationRepositoryProvider.overrideWithValue(_FakeMotivations()),
      cravingRepositoryProvider.overrideWithValue(_FakeCravings()),
      updateRepositoryProvider.overrideWithValue(_FakeUpdates()),
      settingsRepositoryProvider.overrideWithValue(_FakeSettings()),
      statsRepositoryProvider.overrideWithValue(_FakeXp()),
      pushSetupProvider.overrideWith((ref) async {}),
      nowTickerProvider.overrideWith((ref) => Stream.value(_now)),
      healthTimelinesProvider.overrideWith((ref) async => _timelines),
      healthStateProvider.overrideWith(
        (ref) async => const HealthState(HealthAvailability.available, hasAccess: true),
      ),
      healthSyncProvider.overrideWith((ref) async => 0),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    RepaintBoundary(
      key: _shotKey,
      child: UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (context, ref, _) => MaterialApp.router(
            debugShowCheckedModeBanner: false,
            locale: const Locale('fr'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: _themeWithEmoji(),
            themeMode: ThemeMode.dark,
            routerConfig: ref.watch(appRouterProvider),
          ),
        ),
      ),
    ),
  );

  // Session gate → home, then the target screen; animations play out.
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  container.read(appRouterProvider).go(route);
  for (var i = 0; i < 30; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }

  final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(_shotKey));
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: _pixelRatio);
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    File('$_outDir/$name.png')
      ..createSync(recursive: true)
      ..writeAsBytesSync(png!.buffer.asUint8List());
    image.dispose();
  });

  // Unmount so no screen timer outlives the test.
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  final skip = _outDir.isEmpty || _fontsDir.isEmpty
      ? 'README screenshots: run through the Screenshots workflow'
      : null;

  setUpAll(() async {
    if (skip != null) return;
    await initializeDateFormatting('fr_CH');
    final fonts = Directory(_fontsDir).listSync().whereType<File>().toList();
    await _loadFont('Roboto', fonts.where((f) => f.path.contains('Roboto-')));
    await _loadFont('MaterialIcons', fonts.where((f) => f.path.contains('MaterialIcons')));
    await _loadFont(_emojiFont, fonts.where((f) => f.path.contains(_emojiFont)));
    _timelines = HealthTimelines.fromJson(
      jsonDecode(File(healthTimelineAsset).readAsStringSync()) as Map<String, dynamic>,
    );
  });

  testWidgets('home', skip: skip != null, (tester) async {
    await _shoot(tester, name: 'home', route: Routes.home, communityAlert: true);
  });

  testWidgets('quests', skip: skip != null, (tester) async {
    await _shoot(tester, name: 'quests', route: Routes.quests);
  });

  testWidgets('community', skip: skip != null, (tester) async {
    await _shoot(tester, name: 'community', route: Routes.community);
  });

  testWidgets('player', skip: skip != null, (tester) async {
    await _shoot(tester, name: 'player', route: Routes.player(_sarah));
  });

  testWidgets('sos', skip: skip != null, (tester) async {
    await _shoot(tester, name: 'sos', route: Routes.sos(_sosAlert.id, 'a-snus'));
  });

  testWidgets('timeline', skip: skip != null, (tester) async {
    await _shoot(tester, name: 'timeline', route: Routes.timeline('a-snus'));
  });
}
