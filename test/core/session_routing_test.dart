import 'package:detox/core/router/routes.dart';
import 'package:detox/core/session/session_gate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('computeSessionGate', () {
    const loading = AsyncLoading<Object?>();
    SessionGate gate(
      AsyncValue<String?> user, [
      AsyncValue<Object?> profile = loading,
      AsyncValue<Object?> squad = loading,
    ]) => computeSessionGate(userId: user, profile: profile, squad: squad);

    test('auth loading → loading', () {
      expect(gate(const AsyncLoading()), SessionGate.loading);
    });

    test('signed out', () {
      expect(gate(const AsyncData(null)), SessionGate.signedOut);
    });

    test('no profile → onboarding', () {
      expect(
        gate(const AsyncData('u'), const AsyncData(null)),
        SessionGate.needsProfile,
      );
    });

    test('no squad → squad setup', () {
      expect(
        gate(const AsyncData('u'), const AsyncData('p'), const AsyncData(null)),
        SessionGate.needsSquad,
      );
    });

    test('everything ready', () {
      expect(
        gate(const AsyncData('u'), const AsyncData('p'), const AsyncData('s')),
        SessionGate.ready,
      );
    });

    test('profile error → error', () {
      expect(
        gate(
          const AsyncData('u'),
          AsyncError<Object?>(Exception('x'), StackTrace.empty),
        ),
        SessionGate.error,
      );
    });
  });

  group('computeSessionGate with real provider transitions', () {
    late ProviderContainer container;
    final userSource = NotifierProvider<_User, String?>(_User.new);
    final profileProvider = FutureProvider<String?>((ref) async {
      final user = ref.watch(userSource);
      await Future<void>.delayed(const Duration(milliseconds: 5));
      return user == 'alice' ? 'profile-alice' : null;
    });

    SessionGate current() => computeSessionGate(
      userId: AsyncData(container.read(userSource)),
      profile: container.read(profileProvider),
      squad: const AsyncData('squad'),
    );

    setUp(() {
      container = ProviderContainer();
      container.listen(profileProvider, (_, _) {});
    });
    tearDown(() => container.dispose());

    test('switching user shows loading, not the previous user state', () async {
      container.read(userSource.notifier).set('bob');
      await container.read(profileProvider.future);
      expect(current(), SessionGate.needsProfile);

      container.read(userSource.notifier).set('alice');
      expect(current(), SessionGate.loading);
      await container.read(profileProvider.future);
      expect(current(), SessionGate.ready);
    });

    test('a manual refresh keeps the previous value', () async {
      container.read(userSource.notifier).set('alice');
      await container.read(profileProvider.future);
      container.invalidate(profileProvider);
      expect(container.read(profileProvider).isRefreshing, isTrue);
      expect(current(), SessionGate.ready);
    });
  });

  group('Routes.redirect', () {
    test('signed out goes to auth, stays there', () {
      expect(Routes.redirect(SessionGate.signedOut, Routes.home), Routes.auth);
      expect(Routes.redirect(SessionGate.signedOut, Routes.auth), isNull);
    });

    test('onboarding then squad setup', () {
      expect(
        Routes.redirect(SessionGate.needsProfile, Routes.auth),
        Routes.onboarding,
      );
      expect(
        Routes.redirect(SessionGate.needsSquad, Routes.onboarding),
        Routes.squadSetup,
      );
    });

    test('ready leaves gate screens for home', () {
      expect(Routes.redirect(SessionGate.ready, Routes.splash), Routes.home);
      expect(
        Routes.redirect(SessionGate.ready, Routes.squadSetup),
        Routes.home,
      );
      expect(Routes.redirect(SessionGate.ready, Routes.squad), isNull);
      expect(Routes.redirect(SessionGate.ready, Routes.newAddiction), isNull);
    });

    test('loading shows splash', () {
      expect(Routes.redirect(SessionGate.loading, Routes.home), Routes.splash);
      expect(Routes.redirect(SessionGate.loading, Routes.splash), isNull);
    });
  });
}

class _User extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? value) => state = value;
}
