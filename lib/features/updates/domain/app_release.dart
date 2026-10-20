/// A published build, as recorded by the CI in `app_releases`.
class AppRelease {
  const AppRelease({
    required this.versionCode,
    required this.versionName,
    required this.apkUrl,
    this.notes,
    required this.createdAt,
  });

  factory AppRelease.fromJson(Map<String, dynamic> json) => AppRelease(
    versionCode: (json['version_code'] as num).toInt(),
    versionName: json['version_name'] as String,
    apkUrl: json['apk_url'] as String,
    notes: json['notes'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  final int versionCode;
  final String versionName;
  final String apkUrl;
  final String? notes;
  final DateTime createdAt;
}

/// The release to offer, or null. A local build (number 0) never offers one,
/// and a dismissed version is not offered again.
AppRelease? updateToOffer({
  required int currentBuild,
  required AppRelease? latest,
  int? dismissedBuild,
}) {
  if (currentBuild <= 0 || latest == null) return null;
  if (latest.versionCode <= currentBuild) return null;
  if (dismissedBuild != null && latest.versionCode <= dismissedBuild) return null;
  if (!latest.apkUrl.startsWith('https://')) return null;
  return latest;
}
