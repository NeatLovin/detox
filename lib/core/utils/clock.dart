import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clock.g.dart';

/// Local one-second ticker driving the live timers. No network involved.
@riverpod
Stream<DateTime> nowTicker(Ref ref) async* {
  yield DateTime.now();
  yield* Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
}
