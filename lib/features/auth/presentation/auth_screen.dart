import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_messages.dart';
import '../../../core/l10n/l10n.dart';
import '../../../shared/widgets/button_spinner.dart';
import '../data/auth_repository.dart';
import '../domain/auth_rules.dart';

/// Email → 6-digit OTP sign-in. No magic link, so no deep link needed.
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _emailFormKey = GlobalKey<FormState>();
  final _codeFormKey = GlobalKey<FormState>();

  bool _codeSent = false;
  bool _busy = false;
  String? _error;
  DateTime? _lastSentAt;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  int get _secondsLeft =>
      AuthRules.resendSecondsLeft(_lastSentAt, DateTime.now());

  void _startCooldown() {
    _lastSentAt = DateTime.now();
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {});
      if (_secondsLeft == 0) timer.cancel();
    });
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

  Future<void> _sendCode({bool resend = false}) async {
    if (!resend && !_emailFormKey.currentState!.validate()) return;
    await _run(() async {
      await ref.read(authRepositoryProvider).sendOtp(_emailController.text);
      if (!mounted) return;
      setState(() => _codeSent = true);
      _startCooldown();
      if (resend) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.l10n.authCodeResent)));
      }
    });
  }

  Future<void> _verify() async {
    if (!_codeFormKey.currentState!.validate()) return;
    // On success the auth stream updates and the router redirects.
    await _run(
      () => ref
          .read(authRepositoryProvider)
          .verifyOtp(email: _emailController.text, code: _codeController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/brand/logo.png',
                      width: 112,
                      height: 112,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.appTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.authTagline,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 40),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _codeSent
                        ? _buildCodeStep(l10n)
                        : _buildEmailStep(l10n),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailStep(AppLocalizations l10n) {
    return Form(
      key: _emailFormKey,
      child: Column(
        key: const ValueKey('email-step'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.send,
            enabled: !_busy,
            decoration: InputDecoration(
              labelText: l10n.authEmailLabel,
              prefixIcon: const Icon(Icons.alternate_email),
            ),
            validator: (value) => AuthRules.isValidEmail(value ?? '')
                ? null
                : l10n.authEmailInvalid,
            onFieldSubmitted: (_) => _sendCode(),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy ? null : _sendCode,
            child: _busy ? const ButtonSpinner() : Text(l10n.authSendCode),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeStep(AppLocalizations l10n) {
    final secondsLeft = _secondsLeft;
    return Form(
      key: _codeFormKey,
      child: Column(
        key: const ValueKey('code-step'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.authCodeSentTo(_emailController.text.trim()),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            autofillHints: const [AutofillHints.oneTimeCode],
            textAlign: TextAlign.center,
            maxLength: AuthRules.otpLength,
            enabled: !_busy,
            autofocus: true,
            style: const TextStyle(
              fontSize: 28,
              letterSpacing: 12,
              fontWeight: FontWeight.w700,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: l10n.authCodeLabel,
              counterText: '',
            ),
            validator: (value) => AuthRules.isValidOtp(value ?? '')
                ? null
                : l10n.authCodeInvalidFormat,
            onChanged: (value) {
              if (value.length == AuthRules.otpLength && !_busy) _verify();
            },
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy ? null : _verify,
            child: _busy ? const ButtonSpinner() : Text(l10n.authVerify),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _busy || secondsLeft > 0
                ? null
                : () => _sendCode(resend: true),
            child: Text(
              secondsLeft > 0
                  ? l10n.authResendIn(secondsLeft)
                  : l10n.authResend,
            ),
          ),
          TextButton(
            onPressed: _busy
                ? null
                : () => setState(() {
                    _codeSent = false;
                    _error = null;
                    _codeController.clear();
                  }),
            child: Text(l10n.authChangeEmail),
          ),
        ],
      ),
    );
  }
}
