import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/env/env.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../data/update_repository.dart';
import '../domain/app_release.dart';

part 'update_banner.g.dart';

/// Latest published build; errors are swallowed (an update check must never
/// break the home screen).
@riverpod
Future<AppRelease?> latestRelease(Ref ref) async {
  try {
    return await ref.watch(updateRepositoryProvider).fetchLatest();
  } catch (_) {
    return null;
  }
}

/// Version dismissed with "Plus tard" during this session.
@Riverpod(keepAlive: true)
class DismissedUpdate extends _$DismissedUpdate {
  @override
  int? build() => null;

  void dismiss(int versionCode) => state = versionCode;
}

/// "New version available" card on the home screen. Hidden when up to date.
class UpdateBanner extends ConsumerWidget {
  const UpdateBanner({super.key});

  Future<void> _install(BuildContext context, AppRelease release) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final ok = await launchUrl(
      Uri.parse(release.apkUrl),
      mode: LaunchMode.externalApplication,
    );
    if (!ok) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.updateOpenFailed)));
      return;
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.updateDownloadHint),
        duration: const Duration(seconds: 8),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final release = updateToOffer(
      currentBuild: Env.buildNumber,
      latest: ref.watch(latestReleaseProvider).value,
      dismissedBuild: ref.watch(dismissedUpdateProvider),
    );
    if (release == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: AppColors.money.withValues(alpha: 0.12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.system_update, color: AppColors.money),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.updateTitle(release.versionCode),
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              if (release.notes != null && release.notes!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(release.notes!, style: theme.textTheme.bodySmall),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton(
                    onPressed: () => ref
                        .read(dismissedUpdateProvider.notifier)
                        .dismiss(release.versionCode),
                    child: Text(l10n.updateLater),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
                    onPressed: () => _install(context, release),
                    icon: const Icon(Icons.download),
                    label: Text(l10n.updateInstall),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
