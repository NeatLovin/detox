import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/env/env.dart';
import '../../../core/errors/error_messages.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/session/session_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/brand_subtitle.dart';
import '../../auth/data/auth_repository.dart';
import '../../notifications/data/push_repository.dart';
import '../../notifications/domain/notification_prefs.dart';
import '../../notifications/presentation/push_service.dart';
import '../../profile/data/profile_repository.dart';
import '../data/settings_repository.dart';
import '../domain/settings_rules.dart';

/// Preferences (privacy, notifications), donation, account management.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

enum _Setting { isPrivate, notifySos, notifyReminders }

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  /// Values switched by the player but not confirmed by the server yet.
  final _pending = <_Setting, bool>{};
  bool _deleting = false;

  Future<void> _toggle(_Setting setting, bool value) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final profile = ref.read(currentProfileProvider).value;
    if (profile == null) return;

    setState(() => _pending[setting] = value);
    try {
      await ref.read(profileRepositoryProvider).updateSettings(
        userId: profile.id,
        isPrivate: setting == _Setting.isPrivate ? value : null,
        notifySos: setting == _Setting.notifySos ? value : null,
        notifyReminders: setting == _Setting.notifyReminders ? value : null,
      );
      ref.invalidate(currentProfileProvider);
      await ref.read(currentProfileProvider.future);
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(errorMessage(l10n, error))),
      );
    } finally {
      if (mounted) setState(() => _pending.remove(setting));
    }
  }

  Future<void> _signOut() async {
    await unregisterThisDevice(ref.read(pushRepositoryProvider));
    await ref.read(authRepositoryProvider).signOut();
  }

  Future<void> _deleteAccount() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const _DeleteAccountDialog(),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    try {
      // While the session is still valid, so the device stops receiving pushes.
      await unregisterThisDevice(ref.read(pushRepositoryProvider));
      await ref.read(settingsRepositoryProvider).deleteMyAccount();
      await ref.read(authRepositoryProvider).signOutLocally();
      messenger.showSnackBar(SnackBar(content: Text(l10n.settingsDeleted)));
    } catch (error) {
      if (mounted) setState(() => _deleting = false);
      messenger.showSnackBar(
        SnackBar(content: Text(errorMessage(l10n, error))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final profile = ref.watch(currentProfileProvider).value;
    final email = ref.watch(authRepositoryProvider).currentEmail;
    final twintPhone = ref.watch(twintPhoneProvider).value;

    bool valueOf(_Setting setting, bool saved) => _pending[setting] ?? saved;
    ValueChanged<bool>? onChanged(_Setting setting) =>
        profile == null || _pending.containsKey(setting) || _deleting
        ? null
        : (value) => _toggle(setting, value);

    final isPrivate = valueOf(_Setting.isPrivate, profile?.isPrivate ?? false);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _SectionTitle(l10n.settingsPrivacySection),
          Card(
            child: SwitchListTile(
              value: isPrivate,
              secondary: Icon(isPrivate ? Icons.lock : Icons.public),
              title: Text(l10n.profilePrivateToggle),
              subtitle: Text(
                isPrivate ? l10n.profilePrivateOn : l10n.profilePrivateOff,
              ),
              onChanged: onChanged(_Setting.isPrivate),
            ),
          ),
          _SectionTitle(l10n.settingsNotificationsSection),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  value: valueOf(
                    _Setting.notifySos,
                    profile?.notifySos ?? true,
                  ),
                  secondary: const Icon(Icons.sos),
                  title: Text(l10n.notifySosToggle),
                  subtitle: Text(l10n.notifySosHint),
                  onChanged: onChanged(_Setting.notifySos),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: valueOf(
                    _Setting.notifyReminders,
                    profile?.notifyReminders ?? true,
                  ),
                  secondary: const Icon(Icons.notifications_active_outlined),
                  title: Text(l10n.notifyRemindersToggle),
                  subtitle: Text(
                    l10n.notifyRemindersHint(
                      ReminderHours.pledge,
                      ReminderHours.quests,
                    ),
                  ),
                  onChanged: onChanged(_Setting.notifyReminders),
                ),
              ],
            ),
          ),
          if (twintPhone != null) ...[
            _SectionTitle(l10n.donateSection),
            _DonationCard(phone: twintPhone),
          ],
          _SectionTitle(l10n.settingsAccountSection),
          Card(
            child: Column(
              children: [
                if (email != null)
                  ListTile(
                    leading: const Icon(Icons.alternate_email),
                    title: Text(l10n.settingsSignedInAs(email)),
                  ),
                if (email != null) const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: Text(l10n.profileSignOut),
                  enabled: !_deleting,
                  onTap: _signOut,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: _deleting
                      ? const SizedBox.square(
                          dimension: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          Icons.delete_forever_outlined,
                          color: theme.colorScheme.error,
                        ),
                  title: Text(
                    l10n.settingsDeleteAccount,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  subtitle: Text(l10n.settingsDeleteAccountHint),
                  enabled: !_deleting,
                  onTap: _deleteAccount,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Image.asset('assets/brand/logo.png', width: 48, height: 48),
          ),
          const SizedBox(height: 8),
          Text(
            '${l10n.appTitle} · '
            '${l10n.aboutVersion(Env.buildNumber == 0 ? 'dev' : 'build ${Env.buildNumber}')}',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 2),
          const BrandSubtitle(),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Text(
        text.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DonationCard extends StatelessWidget {
  const _DonationCard({required this.phone});

  final String phone;

  Future<void> _copy(BuildContext context) async {
    final message = context.l10n.donateCopied;
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: TwintDonation.normalize(phone)));
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Card(
      color: AppColors.seed.withValues(alpha: 0.14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Text('💜', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(l10n.donateBody, style: theme.textTheme.bodyMedium),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              TwintDonation.format(phone),
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.donateSteps,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => _copy(context),
              icon: const Icon(Icons.copy),
              label: Text(l10n.donateCopy),
            ),
          ],
        ),
      ),
    );
  }
}

/// Second safety net: the delete button only works once the player typed the
/// confirmation word.
class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final confirmed = AccountDeletion.isConfirmed(_controller.text);
    return AlertDialog(
      icon: Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
      title: Text(l10n.settingsDeleteTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.settingsDeleteBody),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autocorrect: false,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: l10n.settingsDeleteConfirmLabel(
                AccountDeletion.confirmationWord,
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          onPressed: confirmed ? () => Navigator.pop(context, true) : null,
          child: Text(l10n.settingsDeleteConfirmButton),
        ),
      ],
    );
  }
}
