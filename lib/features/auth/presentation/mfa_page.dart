import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:monthra/app/router.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/core/network/api_error_text.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/core/network/api_problem.dart';
import 'package:monthra/features/auth/application/auth_controller.dart';
import 'package:monthra/features/auth/presentation/auth_layout.dart';
import 'package:monthra/features/auth/presentation/widgets/auth_fields.dart';
import 'package:monthra/features/auth/presentation/widgets/auth_validators.dart';
import 'package:monthra/features/auth/presentation/widgets/countdown.dart';
import 'package:monthra/features/auth/presentation/widgets/form_alert.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// The second sign-in step: a 6-digit code from the authenticator app, or
/// a recovery code. One field (not one box per digit), so the platform's
/// one-time-code autofill and screen readers handle it as one value.
class MfaPage extends ConsumerStatefulWidget {
  const new({this.from, super.key});

  final String? from;

  @override
  ConsumerState<MfaPage> createState() => _MfaPageState();
}

class _MfaPageState extends ConsumerState<MfaPage> {
  final _form = GlobalKey<ShadFormState>();
  final _code = TextEditingController();
  final _recovery = TextEditingController();
  final _codeFocus = FocusNode();
  final _locked = Countdown();

  bool _useRecovery = false;
  bool _busy = false;
  ApiException? _error;

  @override
  void dispose() {
    _code.dispose();
    _recovery.dispose();
    _codeFocus.dispose();
    _locked.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || _locked.running) return;
    if (!(_form.currentState?.validate() ?? false)) return;
    final code = (_useRecovery ? _recovery.text : _code.text).trim();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).verifyMfa(code);
      // Signed in, or the challenge expired: either way the router moves.
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
      if (e is ApiProblemException) {
        if (e.code == ProblemCode.mfaCodeInvalid) {
          (_useRecovery ? _recovery : _code).clear();
          _codeFocus.requestFocus();
        }
        final wait = e.retryAfter;
        if (e.code == ProblemCode.rateLimited &&
            wait != null &&
            wait > Duration.zero) {
          _locked.start(wait);
        }
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toggleRecovery() => setState(() {
    _useRecovery = !_useRecovery;
    _error = null;
    _form.currentState?.reset();
  });

  void _back() {
    ref.read(authControllerProvider.notifier).cancelMfa();
    context.go(AppRoutes.withFrom(AppRoutes.login, widget.from));
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final l10n = context.l10n;
    final error = _error;
    return AuthLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthHeading(
            title: l10n.authMfaTitle,
            subtitle: _useRecovery
                ? l10n.authMfaRecoverySubtitle
                : l10n.authMfaSubtitle,
          ),
          if (error != null) ...[
            FormAlert.error(l10n.apiError(error)),
            const SizedBox(height: MonthraSpacing.x6),
          ],
          ShadForm(
            key: _form,
            child: AutofillGroup(
              onDisposeAction: AutofillContextAction.cancel,
              child: _useRecovery
                  ? ShadInputFormField(
                      key: const ValueKey('recovery'),
                      id: 'code',
                      controller: _recovery,
                      constraints: authFieldConstraints,
                      focusNode: _codeFocus,
                      autofocus: true,
                      label: Text(l10n.authMfaRecoveryLabel),
                      validator: l10n.validateRequired,
                      autocorrect: false,
                      enableSuggestions: false,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => unawaited(_submit()),
                    )
                  : ShadInputFormField(
                      key: const ValueKey('totp'),
                      id: 'code',
                      controller: _code,
                      constraints: authFieldConstraints,
                      focusNode: _codeFocus,
                      autofocus: true,
                      label: Text(l10n.authMfaCodeLabel),
                      validator: (value) =>
                          value.length == AuthLimits.mfaCodeLength
                          ? null
                          : l10n.errorMfaCodeFormat,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.oneTimeCode],
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(
                          AuthLimits.mfaCodeLength,
                        ),
                      ],
                      // Tabular digits, as amounts are written.
                      style: theme.textTheme.amount.copyWith(
                        color: theme.colorScheme.foreground,
                      ),
                      // The sixth digit sends it: no extra tap.
                      onChanged: (value) {
                        if (value.length == AuthLimits.mfaCodeLength) {
                          unawaited(_submit());
                        }
                      },
                      onSubmitted: (_) => unawaited(_submit()),
                    ),
            ),
          ),
          const SizedBox(height: MonthraSpacing.x6),
          ValueListenableBuilder(
            valueListenable: _locked,
            builder: (context, _, _) => ShadButton(
              enabled: !_busy && !_locked.running,
              onPressed: _submit,
              child: ButtonLabel(l10n.authMfaVerifyButton),
            ),
          ),
          const SizedBox(height: MonthraSpacing.x4),
          Center(
            child: ShadButton.link(
              onPressed: _toggleRecovery,
              child: ButtonLabel(
                _useRecovery ? l10n.authMfaUseApp : l10n.authMfaUseRecovery,
              ),
            ),
          ),
          Center(
            child: ShadButton.link(
              onPressed: _back,
              leading: const Icon(LucideIcons.arrowLeft),
              child: ButtonLabel(l10n.authBackToSignIn),
            ),
          ),
        ],
      ),
    );
  }
}
