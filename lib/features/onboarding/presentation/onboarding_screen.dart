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
import '../../profile/data/motivation_repository.dart';
import '../../profile/data/profile_repository.dart';
import '../../quests/data/quest_repository.dart';
import '../../quests/domain/quest.dart';
import '../../quests/domain/quest_catalog.dart';
import '../../quests/presentation/widgets/quest_draft_tile.dart';
import '../domain/profile_rules.dart';
import 'widgets/emoji_grid.dart';

enum _UsernameStatus { unknown, checking, available, taken }

/// Profile → addictions → daily challenges (quests) → preferences.
const _stepCount = 4;

/// Suggested on first launch: three quests make the all-done bonus reachable.
const _suggestedQuests = [QuestType.water, QuestType.sport, QuestType.sleep];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _usernameController = TextEditingController();
  final _profileFormKey = GlobalKey<FormState>();
  final _addictionsFormKey = GlobalKey<FormState>();
  final _questsFormKey = GlobalKey<FormState>();

  int _step = 0;
  String _avatar = ProfileRules.avatarEmojis.first;
  _UsernameStatus _usernameStatus = _UsernameStatus.unknown;
  Timer? _debounce;
  final _drafts = <AddictionType, AddictionDraft>{};
  final _quests = <QuestType, QuestDraft>{
    for (final type in _suggestedQuests) type: QuestCatalog.draftFor(type),
  };
  bool _isPrivate = false;
  final _motivations = <TextEditingController>[TextEditingController()];
  bool _busy = false;
  // Each part is saved once: a retry after a failure never duplicates rows.
  bool _profileCreated = false;
  bool _addictionsCreated = false;
  bool _questsCreated = false;
  String? _error;

  @override
  void dispose() {
    _debounce?.cancel();
    _usernameController.dispose();
    for (final c in _motivations) {
      c.dispose();
    }
    super.dispose();
  }

  void _goTo(int step) => setState(() {
    _step = step;
    _error = null;
  });

  void _goToQuests() {
    if (_drafts.isEmpty) {
      setState(() => _error = context.l10n.onboardingSelectAtLeastOne);
      return;
    }
    if (!_addictionsFormKey.currentState!.validate()) return;
    _goTo(2);
  }

  void _goToPreferences() {
    if (!_questsFormKey.currentState!.validate()) return;
    _goTo(3);
  }

  void _toggleQuest(QuestType type, bool selected) {
    setState(() {
      if (selected) {
        _quests[type] = QuestCatalog.draftFor(type);
      } else {
        _quests.remove(type);
      }
    });
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
      if (status != _UsernameStatus.taken) {
        _step = 1;
        _error = null;
      }
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
              isPrivate: _isPrivate,
            );
        _profileCreated = true;
      }
      if (!_addictionsCreated) {
        await ref
            .read(addictionRepositoryProvider)
            .createAll(_drafts.values.toList());
        _addictionsCreated = true;
      }
      if (!_questsCreated) {
        await ref
            .read(questRepositoryProvider)
            .createAll(_quests.values.toList());
        _questsCreated = true;
      }
      await ref
          .read(motivationRepositoryProvider)
          .addAll([for (final c in _motivations) c.text]);
      // Refreshing the profile moves the router on to the home screen.
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
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_busy) _goTo(_step - 1);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.onboardingStep(_step + 1, _stepCount)),
          leading: _step > 0
              ? BackButton(onPressed: _busy ? null : () => _goTo(_step - 1))
              : null,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(value: (_step + 1) / _stepCount),
          ),
        ),
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: switch (_step) {
              0 => _buildProfileStep(l10n),
              1 => _buildAddictionsStep(l10n),
              2 => _buildQuestsStep(l10n),
              _ => _buildPreferencesStep(l10n),
            },
          ),
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
            onPressed: _busy ? null : _goToQuests,
            child: Text(l10n.commonContinue),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestsStep(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final atCap = _quests.length >= QuestLimits.maxActive;
    return Form(
      key: _questsFormKey,
      child: ListView(
        key: const ValueKey('quests-step'),
        padding: const EdgeInsets.all(24),
        children: [
          Text(l10n.onboardingQuestsTitle, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(l10n.onboardingQuestsSubtitle),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final preset in QuestCatalog.presets)
                FilterChip(
                  avatar: Text(preset.emoji),
                  label: Text(l10n.questTypeLabel(preset.type.dbValue)),
                  selected: _quests.containsKey(preset.type),
                  onSelected: _busy || (atCap && !_quests.containsKey(preset.type))
                      ? null
                      : (value) => _toggleQuest(preset.type, value),
                ),
            ],
          ),
          const SizedBox(height: 16),
          for (final entry in _quests.entries) ...[
            QuestDraftTile(
              key: ValueKey(entry.key),
              draft: entry.value,
              onChanged: (draft) => _quests[entry.key] = draft,
              onRemove: () => _toggleQuest(entry.key, false),
            ),
            const SizedBox(height: 12),
          ],
          if (_quests.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                l10n.onboardingQuestsNone,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ),
          FilledButton(
            onPressed: _busy ? null : _goToPreferences,
            child: Text(l10n.commonContinue),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesStep(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return ListView(
      key: const ValueKey('preferences-step'),
      padding: const EdgeInsets.all(24),
      children: [
        Text(l10n.onboardingPrefsTitle, style: theme.textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(l10n.onboardingPrefsSubtitle),
        const SizedBox(height: 16),
        Card(
          child: SwitchListTile(
            value: _isPrivate,
            secondary: Icon(_isPrivate ? Icons.lock : Icons.public),
            title: Text(l10n.profilePrivateToggle),
            subtitle: Text(
              _isPrivate ? l10n.profilePrivateOn : l10n.profilePrivateOff,
            ),
            onChanged: _busy ? null : (v) => setState(() => _isPrivate = v),
          ),
        ),
        const SizedBox(height: 24),
        Text(l10n.motivationsTitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(l10n.onboardingMotivationsSubtitle, style: theme.textTheme.bodySmall),
        const SizedBox(height: 12),
        for (final (index, controller) in _motivations.indexed) ...[
          TextField(
            controller: controller,
            enabled: !_busy,
            maxLength: 140,
            decoration: InputDecoration(
              hintText: index == 0 ? l10n.motivationsHint : null,
              prefixIcon: const Icon(Icons.favorite_outline),
            ),
          ),
          const SizedBox(height: 4),
        ],
        if (_motivations.length < maxMotivations)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _busy
                  ? null
                  : () => setState(() => _motivations.add(TextEditingController())),
              icon: const Icon(Icons.add),
              label: Text(l10n.motivationsAdd),
            ),
          ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ],
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _busy ? null : _finish,
          child: _busy ? const ButtonSpinner() : Text(l10n.onboardingFinish),
        ),
      ],
    );
  }
}
