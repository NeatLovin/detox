import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_messages.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/session/session_providers.dart';
import '../../../shared/widgets/button_spinner.dart';
import '../../onboarding/domain/profile_rules.dart';
import '../../onboarding/presentation/widgets/emoji_grid.dart';
import '../data/profile_repository.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _usernameController = TextEditingController(
    text: ref.read(currentProfileProvider).value?.username ?? '',
  );
  late String _avatar =
      ref.read(currentProfileProvider).value?.avatarEmoji ??
      ProfileRules.avatarEmojis.first;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = context.l10n;
    final profile = ref.read(currentProfileProvider).value;
    if (profile == null) return;

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final repository = ref.read(profileRepositoryProvider);
      final username = _usernameController.text.trim();
      if (username.toLowerCase() != profile.username.toLowerCase() &&
          !await repository.isUsernameAvailable(username)) {
        setState(() {
          _busy = false;
          _error = l10n.errorUsernameTaken;
        });
        return;
      }
      await repository.updateProfile(
        userId: profile.id,
        username: username,
        avatarEmoji: _avatar,
      );
      ref.invalidate(currentProfileProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.profileUpdated)));
      Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = errorMessage(l10n, error);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileEdit)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(child: Text(_avatar, style: const TextStyle(fontSize: 72))),
            const SizedBox(height: 16),
            TextFormField(
              controller: _usernameController,
              maxLength: 20,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: l10n.onboardingUsernameLabel,
                helperText: l10n.errorUsernameInvalid,
              ),
              validator: (value) => ProfileRules.isValidUsername(value ?? '')
                  ? null
                  : l10n.errorUsernameInvalid,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.onboardingAvatarTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            EmojiGrid(
              selected: _avatar,
              onSelected: (emoji) => setState(() => _avatar = emoji),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _busy ? null : _save,
              child: _busy ? const ButtonSpinner() : Text(l10n.commonSave),
            ),
          ],
        ),
      ),
    );
  }
}
