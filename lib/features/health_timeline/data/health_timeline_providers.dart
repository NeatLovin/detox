import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/health_timeline.dart';

part 'health_timeline_providers.g.dart';

const healthTimelineAsset = 'assets/content/health_timeline_fr.json';

/// Bundled content: loaded once, never from the network.
@Riverpod(keepAlive: true)
Future<HealthTimelines> healthTimelines(Ref ref) async {
  final raw = await rootBundle.loadString(healthTimelineAsset);
  return HealthTimelines.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}
