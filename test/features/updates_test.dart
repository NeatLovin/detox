import 'package:detox/features/updates/domain/app_release.dart';
import 'package:flutter_test/flutter_test.dart';

AppRelease release(int code, {String url = 'https://x.supabase.co/a.apk'}) => AppRelease(
  versionCode: code,
  versionName: 'build $code',
  apkUrl: url,
  createdAt: DateTime(2026, 10, 20),
);

void main() {
  test('offers a newer build only', () {
    expect(updateToOffer(currentBuild: 10, latest: release(11))?.versionCode, 11);
    expect(updateToOffer(currentBuild: 11, latest: release(11)), isNull);
    expect(updateToOffer(currentBuild: 12, latest: release(11)), isNull);
    expect(updateToOffer(currentBuild: 10, latest: null), isNull);
  });

  test('local builds (number 0) never offer an update', () {
    expect(updateToOffer(currentBuild: 0, latest: release(11)), isNull);
  });

  test('a dismissed version is not offered again, a newer one is', () {
    expect(updateToOffer(currentBuild: 10, latest: release(11), dismissedBuild: 11), isNull);
    expect(
      updateToOffer(currentBuild: 10, latest: release(12), dismissedBuild: 11)?.versionCode,
      12,
    );
  });

  test('only https links are opened', () {
    expect(updateToOffer(currentBuild: 10, latest: release(11, url: 'http://x/a.apk')), isNull);
  });

  test('parses an app_releases row', () {
    final r = AppRelease.fromJson({
      'version_code': 11,
      'version_name': 'build 11',
      'apk_url': 'https://x.supabase.co/storage/v1/object/public/releases/detox-arm64-11.apk',
      'notes': 'feat: icon',
      'created_at': '2026-10-20T17:00:00Z',
    });
    expect(r.versionCode, 11);
    expect(r.notes, 'feat: icon');
  });
}
