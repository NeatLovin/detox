import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/day.dart';
import '../domain/health_sync.dart';

part 'health_repository.g.dart';

/// Availability of Health Connect on this phone.
enum HealthAvailability { unsupported, notInstalled, available }

/// Read-only access to Health Connect (steps, sleep, workouts).
/// The only file that depends on the `health` package.
class HealthRepository {
  HealthRepository(this._health);

  final Health _health;
  bool _configured = false;

  static const _types = [
    HealthDataType.STEPS,
    HealthDataType.SLEEP_SESSION,
    HealthDataType.WORKOUT,
  ];
  static final _permissions = [for (final _ in _types) HealthDataAccess.READ];

  Future<void> _configure() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  Future<HealthAvailability> availability() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return HealthAvailability.unsupported;
    }
    try {
      await _configure();
      final status = await _health.getHealthConnectSdkStatus();
      return status == HealthConnectSdkStatus.sdkAvailable
          ? HealthAvailability.available
          : HealthAvailability.notInstalled;
    } catch (_) {
      return HealthAvailability.unsupported;
    }
  }

  /// Opens the Play Store page of Health Connect.
  Future<void> install() async {
    await _configure();
    await _health.installHealthConnect();
  }

  Future<bool> hasAccess() async {
    try {
      await _configure();
      return await _health.hasPermissions(_types, permissions: _permissions) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Shows the Health Connect permission screen.
  Future<bool> requestAccess() async {
    await _configure();
    return _health.requestAuthorization(_types, permissions: _permissions);
  }

  /// Today's steps and workouts, and last night's sleep.
  Future<HealthReading> readToday(DateTime now) async {
    await _configure();
    final midnight = dayOf(now);

    int? steps;
    try {
      steps = await _health.getTotalStepsInInterval(midnight, now);
    } catch (_) {}

    int? minutesOf(List<HealthDataPoint> points) {
      if (points.isEmpty) return null;
      var total = 0;
      for (final p in points) {
        total += p.dateTo.difference(p.dateFrom).inMinutes;
      }
      return total;
    }

    int? sleep;
    try {
      final points = await _health.getHealthDataFromTypes(
        types: const [HealthDataType.SLEEP_SESSION],
        startTime: sleepWindowStart(now),
        endTime: now,
      );
      sleep = minutesOf(_health.removeDuplicates(points));
    } catch (_) {}

    int? workout;
    try {
      final points = await _health.getHealthDataFromTypes(
        types: const [HealthDataType.WORKOUT],
        startTime: midnight,
        endTime: now,
      );
      workout = minutesOf(_health.removeDuplicates(points));
    } catch (_) {}

    return HealthReading(steps: steps, sleepMinutes: sleep, workoutMinutes: workout);
  }
}

@Riverpod(keepAlive: true)
HealthRepository healthRepository(Ref ref) => HealthRepository(Health());
