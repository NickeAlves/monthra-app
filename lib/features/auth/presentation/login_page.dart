import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:monthra/app/router.dart';
import 'package:monthra/core/config/env_provider.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/core/forms/countdown.dart';
import 'package:monthra/core/forms/fields.dart';
import 'package:monthra/core/forms/form_alert.dart';
import 'package:monthra/core/network/api_error_text.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/core/network/api_problem.dart';
import 'package:monthra/features/auth/application/auth_controller.dart';
import 'package:monthra/features/auth/application/auth_state.dart';
import 'package:monthra/features/auth/captcha/captcha_field.dart';
import 'package:monthra/features/auth/captcha/captcha_gate.dart';
import 'package:monthra/features/auth/captcha/captcha_request.dart';
import 'package:monthra/features/auth/data/auth_api.dart';
import 'package:monthra/features/auth/presentation/auth_layout.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Email and password. A right password on an account with two-step
/// verification moves on to the MFA page; signed in, the router goes on to
/// [from] (a path of this app, checked by the router) or home. After
/// repeated failures the server asks for a security check: the page shows
/// it and signs in again by itself once it passes.
class LoginPage extends ConsumerStatefulWidget {
  const new({this.from, super.key});

  final String? from;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _form = GlobalKey<ShadFormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _passwordFocus = FocusNode();

  /// The wait a `429` asked for: the button stays off until it ends.
  final _locked = Countdown();
  final _resendWait = Countdown();
  late final CaptchaGate _captcha;

  bool _busy = false;
  ApiException? _error;
  String? _resentTo;

  @override
  void initState() {
    super.initState();
    _locked.addListener(_onLockChanged);
    _captcha = CaptchaGate(available: ref.read(envProvider).captchaPage != null)
      ..addListener(_onCaptchaChanged);
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _passwordFocus.dispose();
    _locked
      ..removeListener(_onLockChanged)
      ..dispose();
    _resendWait.dispose();
    _captcha
      ..removeListener(_onCaptchaChanged)
      ..dispose();
    super.dispose();
  }

  void _onCaptchaChanged() => setState(() {});

  void _onLockChanged() {
    // The wait is over: the "try again in N s" alert goes with it.
    if (!_locked.running && _isRateLimited(_error)) {
      setState(() => _error = null);
    }
  }

  Future<void> _submit() async {
    if (_busy || _locked.running || _captcha.waitingForToken) return;
    if (!(_form.currentState?.validate() ?? false)) return;
    final captchaToken = _captcha.take();
    setState(() {
      _busy = true;
      _error = null;
      _resentTo = null;
    });
    try {
      await ref
          .read(authControllerProvider.notifier)
          .signIn(
            email: _email.text.trim(),
            password: _password.text,
            captchaToken: captchaToken,
          );
      // The password was right: let the password manager save it.
      TextInput.finishAutofillContext();
      if (!mounted) return;
      if (ref.read(authControllerProvider) is AwaitingMfa) {
        _password.clear();
        context.go(AppRoutes.withFrom(AppRoutes.mfa, widget.from));
      }
      // Signed in: the router already moves on.
    } on ApiException catch (e) {
      if (!mounted) return;
      _captcha.onError(e);
      setState(() => _error = e);
      if (e is ApiProblemException && e.code == ProblemCode.rateLimited) {
        final wait = e.retryAfter;
        if (wait != null && wait > Duration.zero) _locked.start(wait);
      }
      // Back to the password, so a typo is fixed (or Enter sends again)
      // without reaching for the field.
      _passwordFocus.requestFocus();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resendVerification() async {
    final email = _email.text.trim();
    setState(() => _busy = true);
    try {
      await ref.read(authApiProvider).resendVerification(email);
      if (!mounted) return;
      _resendWait.start(resendCooldown);
      setState(() {
        _error = null;
        _resentTo = email;
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  static bool _isRateLimited(ApiException? e) =>
      e is ApiProblemException && e.code == ProblemCode.rateLimited;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final auth = ref.watch(authControllerProvider);
    final notice = auth is SignedOut ? auth.notice : null;
    return AuthLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthHeading(
            title: l10n.authSignInTitle,
            subtitle: l10n.authSignInSubtitle,
          ),
          ..._alert(l10n, notice),
          ShadForm(
            key: _form,
            child: AutofillGroup(
              // Only a sign-in that worked offers to save the password.
              onDisposeAction: AutofillContextAction.cancel,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  EmailField(controller: _email),
                  const SizedBox(height: MonthraSpacing.x4),
                  PasswordField(
                    controller: _password,
                    focusNode: _passwordFocus,
                    onSubmitted: (_) => unawaited(_submit()),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: MonthraTapTarget(
              child: ShadButton.link(
                onPressed: () => context.go(AppRoutes.forgotPassword),
                child: ButtonLabel(l10n.authForgotPasswordLink),
              ),
            ),
          ),
          const SizedBox(height: MonthraSpacing.x2),
          if (_captcha.needed) ...[
            CaptchaField(
              gate: _captcha,
              action: CaptchaAction.login,
              onResend: () => unawaited(_submit()),
            ),
            const SizedBox(height: MonthraSpacing.x4),
          ],
          ValueListenableBuilder(
            valueListenable: _locked,
            builder: (context, _, _) => MonthraTapTarget(
              child: ShadButton(
                enabled:
                    !_busy && !_locked.running && !_captcha.waitingForToken,
                onPressed: _submit,
                child: ButtonLabel(l10n.authSignInButton),
              ),
            ),
          ),
          const SizedBox(height: MonthraSpacing.x6),
          AuthSwitchLink(
            text: l10n.authNoAccount,
            link: l10n.authCreateAccountLink,
            onPressed: () => context.go(AppRoutes.register),
          ),
        ],
      ),
    );
  }

  List<Widget> _alert(AppLocalizations l10n, AuthNotice? notice) {
    final error = _error;
    final resentTo = _resentTo;
    final Widget alert;
    final captcha = captchaAlert(l10n, _captcha, error);
    if (captcha != null) {
      alert = captcha;
    } else if (error != null) {
      final unverified =
          error is ApiProblemException &&
          error.code == ProblemCode.emailNotVerified;
      alert = _isRateLimited(error)
          ? ValueListenableBuilder(
              valueListenable: _locked,
              builder: (context, seconds, _) => FormAlert.error((
                message: seconds > 0
                    ? l10n.errorRateLimited(seconds)
                    : l10n.errorRateLimitedSoon,
                reference: null,
              )),
            )
          : FormAlert.error(
              l10n.apiError(error),
              action: unverified ? _resendButton(l10n) : null,
            );
    } else if (resentTo != null) {
      alert = FormAlert(
        message: l10n.authVerificationSent(resentTo),
        icon: LucideIcons.mailCheck,
      );
    } else if (notice != null) {
      alert = FormAlert(message: noticeText(l10n, notice));
    } else {
      return const [];
    }
    return [alert, const SizedBox(height: MonthraSpacing.x6)];
  }

  Widget _resendButton(AppLocalizations l10n) => ValueListenableBuilder(
    valueListenable: _resendWait,
    builder: (context, seconds, _) => MonthraTapTarget(
      child: ShadButton.outline(
        enabled: !_busy && seconds == 0,
        onPressed: _resendVerification,
        leading: const Icon(LucideIcons.mail),
        child: ButtonLabel(
          seconds > 0
              ? l10n.authResendIn(seconds)
              : l10n.authResendVerification,
        ),
      ),
    ),
  );
}

/// The sentence for [notice] on the sign-in page.
String noticeText(AppLocalizations l10n, AuthNotice notice) => switch (notice) {
  AuthNotice.sessionExpired => l10n.authNoticeSessionExpired,
  AuthNotice.passwordReset => l10n.authNoticePasswordReset,
  AuthNotice.mfaExpired => l10n.authNoticeMfaExpired,
  AuthNotice.accountDeleted => l10n.authNoticeAccountDeleted,
};
