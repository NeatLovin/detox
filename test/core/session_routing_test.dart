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
    ]) =>
        computeSessionGate(userId: user, profile: profile, squad: squad);

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

    test('refreshing keeps previous value', () {
      const refreshing = AsyncLoading<Object?>();
      final withPrevious =
          refreshing.copyWithPrevious(const AsyncData<Object?>('p'));
      expect(
        gate(const AsyncData('u'), withPrevious, const AsyncData('s')),
        SessionGate.ready,
      );
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
      expect(Routes.redirect(SessionGate.ready, Routes.squadSetup), Routes.home);
      expect(Routes.redirect(SessionGate.ready, Routes.squad), isNull);
      expect(Routes.redirect(SessionGate.ready, Routes.newAddiction), isNull);
    });

    test('loading shows splash', () {
      expect(Routes.redirect(SessionGate.loading, Routes.home), Routes.splash);
      expect(Routes.redirect(SessionGate.loading, Routes.splash), isNull);
    });
  });
}
