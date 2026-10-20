import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_messages.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/session/session_providers.dart';
import '../../../shared/widgets/button_spinner.dart';
import '../data/squad_repository.dart';
import '../domain/squad.dart';
import '../domain/squad_rules.dart';
import 'widgets/invite_code_card.dart';

/// Create a squad or join one with an invite code.
class SquadSetupScreen extends ConsumerStatefulWidget {
  const SquadSetupScreen({super.key});

  @override
  ConsumerState<SquadSetupScreen> createState() => _SquadSetupScreenState();
}

class _SquadSetupScreenState extends ConsumerState<SquadSetupScreen> {
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _createFormKey = GlobalKey<FormState>();
  final _joinFormKey = GlobalKey<FormState>();

  bool _busy = false;
  String? _error;

  /// Set after creation: the invite code is shown before entering the app.
  Squad? _created;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } catch (error) {
      if (mounted) setState(() => _error = errorMessage(context.l10n, error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _create() async {
    if (!_createFormKey.currentState!.validate()) return;
    await _run(() async {
      final squad = await ref
          .read(squadRepositoryProvider)
          .createSquad(_nameController.text);
      if (mounted) setState(() => _created = squad);
    });
  }

  Future<void> _join() async {
    if (!_joinFormKey.currentState!.validate()) return;
    await _run(() async {
      await ref.read(squadRepositoryProvider).joinSquad(_codeController.text);
      // The router redirects to the home shell once the squad is loaded.
      ref.invalidate(currentSquadProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final created = _created;
    return Scaffold(
      body: SafeArea(
        child: created != null
            ? _buildCreated(l10n, created)
            : DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    const Text('🛡️', style: TextStyle(fontSize: 56)),
                    Text(
                      l10n.squadSetupTitle,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(l10n.squadSetupSubtitle),
                    const SizedBox(height: 16),
                    TabBar(
                      onTap: (_) => setState(() => _error = null),
                      tabs: [
                        Tab(text: l10n.squadCreateTab),
                        Tab(text: l10n.squadJoinTab),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [_buildCreateTab(l10n), _buildJoinTab(l10n)],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildCreateTab(AppLocalizations l10n) {
    return Form(
      key: _createFormKey,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextFormField(
            controller: _nameController,
            maxLength: 40,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: l10n.squadNameLabel,
              prefixIcon: const Icon(Icons.shield_outlined),
            ),
            validator: (value) =>
                (value ?? '').trim().isEmpty ? l10n.commonRequired : null,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy ? null : _create,
            child: _busy ? const ButtonSpinner() : Text(l10n.squadCreateButton),
          ),
          _ErrorText(_error),
        ],
      ),
    );
  }

  Widget _buildJoinTab(AppLocalizations l10n) {
    return Form(
      key: _joinFormKey,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextFormField(
            controller: _codeController,
            maxLength: 6,
            textAlign: TextAlign.center,
            textCapitalization: TextCapitalization.characters,
            autocorrect: false,
            style: const TextStyle(
              fontSize: 28,
              letterSpacing: 10,
              fontWeight: FontWeight.w800,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
              TextInputFormatter.withFunction(
                (oldValue, newValue) =>
                    newValue.copyWith(text: newValue.text.toUpperCase()),
              ),
            ],
            decoration: InputDecoration(
              labelText: l10n.squadCodeLabel,
              counterText: '',
            ),
            validator: (value) => SquadRules.isValidInviteCode(value ?? '')
                ? null
                : l10n.errorInvalidInviteCode,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy ? null : _join,
            child: _busy ? const ButtonSpinner() : Text(l10n.squadJoinButton),
          ),
          _ErrorText(_error),
        ],
      ),
    );
  }

  Widget _buildCreated(AppLocalizations l10n, Squad squad) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 24),
        Text(
          l10n.squadCreatedTitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(l10n.squadCreatedBody, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        InviteCodeCard(squad: squad),
        const SizedBox(height: 32),
        FilledButton(
          onPressed: () => ref.invalidate(currentSquadProvider),
          child: Text(l10n.squadEnter),
        ),
      ],
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.error);

  final String? error;

  @override
  Widget build(BuildContext context) {
    if (error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Text(
        error!,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
  }
}
