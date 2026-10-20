import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_messages.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/session/session_providers.dart';
import '../../../shared/widgets/button_spinner.dart';
import '../../addictions/data/addiction_repository.dart';
import '../../addictions/domain/addiction.dart';
import '../../addictions/domain/addiction_catalog.dart';
import '../../addictions/domain/addiction_limits.dart';
import '../../addictions/presentation/widgets/addiction_draft_form.dart';
import '../../addictions/presentation/widgets/addiction_type_label.dart';
import '../../profile/data/profile_repository.dart';
import '../domain/profile_rules.dart';
import 'widgets/emoji_grid.dart';

enum _UsernameStatus { unknown, checking, available, taken }

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _usernameController = TextEditingController();
  final _profileFormKey = GlobalKey<FormState>();
  final _addictionsFormKey = GlobalKey<FormState>();

  int _step = 0;
  String _avatar = ProfileRules.avatarEmojis.first;
  _UsernameStatus _usernameStatus = _UsernameStatus.unknown;
  Timer? _debounce;
  final _drafts = <AddictionType, AddictionDraft>{};
  bool _busy = false;
  bool _profileCreated = false;
  String? _error;

  @override
  void dispose() {
    _debounce?.cancel();
    _usernameController.dispose();
    super.dispose();
  }

  void _onUsernameChanged(String value) {
    _debounce?.cancel();
    if (!ProfileRules.isValidUsername(value)) {
      setState(() => _usernameStatus = _UsernameStatus.unknown);
      return;
    }
    setState(() => _usernameStatus = _UsernameStatus.checking);
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final status = await _checkUsername(value);
      if (mounted && _usernameController.text == value) {
        setState(() => _usernameStatus = status);
      }
    });
  }

  Future<_UsernameStatus> _checkUsername(String value) async {
    try {
      final available = await ref
          .read(profileRepositoryProvider)
          .isUsernameAvailable(value);
      return available ? _UsernameStatus.available : _UsernameStatus.taken;
    } catch (_) {
      return _UsernameStatus.unknown;
    }
  }

  Future<void> _goToAddictions() async {
    if (!_profileFormKey.currentState!.validate()) return;
    setState(() => _busy = true);
    final status = await _checkUsername(_usernameController.text);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _usernameStatus = status;
      if (status != _UsernameStatus.taken) _step = 1;
    });
    _profileFormKey.currentState!.validate();
  }

  void _toggle(AddictionType type, bool selected) {
    setState(() {
      if (selected) {
        _drafts[type] = AddictionCatalog.draftFor(type);
      } else {
        _drafts.remove(type);
      }
      _error = null;
    });
  }

  Future<void> _finish() async {
    final l10n = context.l10n;
    if (_drafts.isEmpty) {
      setState(() => _error = l10n.onboardingSelectAtLeastOne);
      return;
    }
    if (!_addictionsFormKey.currentState!.validate()) return;

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final userId = await ref.read(authStateProvider.future);
      if (userId == null) return;
      if (!_profileCreated) {
        await ref
            .read(profileRepositoryProvider)
            .createProfile(
              userId: userId,
              username: _usernameController.text,
              avatarEmoji: _avatar,
            );
        _profileCreated = true;
      }
      await ref
          .read(addictionRepositoryProvider)
          .createAll(_drafts.values.toList());
      // Refreshing the profile moves the router on to the squad setup.
      ref.invalidate(currentProfileProvider);
    } catch (error) {
      if (!mounted) return;
      final usernameIssue =
          !_profileCreated &&
          const {
            'unique_violation',
            'check_violation',
          }.contains(errorCode(error));
      setState(() {
        _error = errorMessage(l10n, error);
        if (usernameIssue) {
          _step = 0;
          _usernameStatus = _UsernameStatus.taken;
        }
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.onboardingStep(_step + 1, 2)),
        leading: _step == 1
            ? BackButton(onPressed: () => setState(() => _step = 0))
            : null,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: (_step + 1) / 2),
        ),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _step == 0
              ? _buildProfileStep(l10n)
              : _buildAddictionsStep(l10n),
        ),
      ),
    );
  }

  Widget _buildProfileStep(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final suffix = switch (_usernameStatus) {
      _UsernameStatus.checking => const Padding(
        padding: EdgeInsets.all(14),
        child: SizedBox.square(
          dimension: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      _UsernameStatus.available => const Icon(
        Icons.check_circle,
        color: Colors.greenAccent,
      ),
      _UsernameStatus.taken => Icon(
        Icons.cancel,
        color: theme.colorScheme.error,
      ),
      _UsernameStatus.unknown => null,
    };

    return Form(
      key: _profileFormKey,
      child: ListView(
        key: const ValueKey('profile-step'),
        padding: const EdgeInsets.all(24),
        children: [
          Center(child: Text(_avatar, style: const TextStyle(fontSize: 72))),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingProfileTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _usernameController,
            maxLength: 20,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: l10n.onboardingUsernameLabel,
              helperText: _usernameStatus == _UsernameStatus.available
                  ? l10n.onboardingUsernameAvailable
                  : l10n.errorUsernameInvalid,
              suffixIcon: suffix,
            ),
            validator: (value) {
              if (!ProfileRules.isValidUsername(value ?? '')) {
                return l10n.errorUsernameInvalid;
              }
              if (_usernameStatus == _UsernameStatus.taken) {
                return l10n.errorUsernameTaken;
              }
              return null;
            },
            onChanged: _onUsernameChanged,
          ),
          const SizedBox(height: 16),
          Text(l10n.onboardingAvatarTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          EmojiGrid(
            selected: _avatar,
            onSelected: (emoji) => setState(() => _avatar = emoji),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _busy ? null : _goToAddictions,
            child: _busy ? const ButtonSpinner() : Text(l10n.commonContinue),
          ),
        ],
      ),
    );
  }

  Widget _buildAddictionsStep(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Form(
      key: _addictionsFormKey,
      child: ListView(
        key: const ValueKey('addictions-step'),
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            l10n.onboardingAddictionsTitle,
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(l10n.onboardingAddictionsSubtitle),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final preset in AddictionCatalog.presets)
                FilterChip(
                  avatar: Text(preset.emoji),
                  label: Text(addictionTypeLabel(l10n, preset.type)),
                  selected: _drafts.containsKey(preset.type),
                  // Unselected chips are disabled once the cap is reached.
                  onSelected:
                      _busy ||
                          (!_drafts.containsKey(preset.type) &&
                              !AddictionLimits.canAdd(
                                _drafts.keys,
                                preset.type,
                              ))
                      ? null
                      : (value) => _toggle(preset.type, value),
                ),
            ],
          ),
          const SizedBox(height: 16),
          for (final entry in _drafts.entries) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '${AddictionCatalog.of(entry.key).emoji}  '
                      '${addictionTypeLabel(l10n, entry.key)}',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    AddictionDraftForm(
                      key: ValueKey(entry.key),
                      draft: entry.value,
                      onChanged: (draft) =>
                          setState(() => _drafts[entry.key] = draft),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (_error != null) ...[
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.error),
            ),
            const SizedBox(height: 12),
          ],
          FilledButton(
            onPressed: _busy ? null : _finish,
            child: _busy ? const ButtonSpinner() : Text(l10n.onboardingFinish),
          ),
        ],
      ),
    );
  }
}
