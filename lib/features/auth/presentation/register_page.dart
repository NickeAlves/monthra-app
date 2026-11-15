import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:monthra/app/router.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/core/network/api_error_text.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/features/auth/data/auth_api.dart';
import 'package:monthra/features/auth/presentation/auth_layout.dart';
import 'package:monthra/features/auth/presentation/widgets/auth_fields.dart';
import 'package:monthra/features/auth/presentation/widgets/auth_validators.dart';
import 'package:monthra/features/auth/presentation/widgets/countdown.dart';
import 'package:monthra/features/auth/presentation/widgets/form_alert.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Name, email and password. The answer is the same whether or not the
/// address is taken (no enumeration), so the page always moves on to
/// "check your inbox".
class RegisterPage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _form = GlobalKey<ShadFormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _resendWait = Countdown();

  bool _busy = false;
  ApiException? _error;
  String? _sentTo;
  bool _resent = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _resendWait.dispose();
    super.dispose();
  }

  ApiProblemException? get _problem => switch (_error) {
    final ApiProblemException p => p,
    _ => null,
  };

  Future<void> _submit() async {
    if (_busy) return;
    setState(() => _error = null);
    if (!(_form.currentState?.validate() ?? false)) return;
    final email = _email.text.trim();
    setState(() => _busy = true);
    try {
      await ref
          .read(authApiProvider)
          .register(
            name: _name.text.trim(),
            email: email,
            password: _password.text,
          );
      TextInput.finishAutofillContext();
      if (!mounted) return;
      _password.clear();
      _resendWait.start(resendCooldown);
      setState(() => _sentTo = email);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    final email = _sentTo;
    if (email == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authApiProvider).resendVerification(email);
      if (!mounted) return;
      _resendWait.start(resendCooldown);
      setState(() => _resent = true);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _clearServerError(String field) {
    if (_problem?.problem.codesOf(field).isNotEmpty ?? false) {
      setState(() => _error = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sentTo = _sentTo;
    return AuthLayout(
      child: sentTo == null ? _formView(context) : _sentView(context, sentTo),
    );
  }

  Widget _formView(BuildContext context) {
    final l10n = context.l10n;
    final error = _error;
    final problem = _problem?.problem;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthHeading(
          title: l10n.authRegisterTitle,
          subtitle: l10n.authRegisterSubtitle,
        ),
        if (error != null) ...[
          FormAlert.error(l10n.apiError(error)),
          const SizedBox(height: MonthraSpacing.x6),
        ],
        ShadForm(
          key: _form,
          child: AutofillGroup(
            onDisposeAction: AutofillContextAction.cancel,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ShadInputFormField(
                  id: 'name',
                  controller: _name,
                  constraints: authFieldConstraints,
                  label: Text(l10n.authNameLabel),
                  validator: l10n.validateName,
                  forceErrorText: l10n.serverFieldError(
                    problem,
                    'name',
                    max: AuthLimits.nameMax,
                  ),
                  autofillHints: const [AutofillHints.name],
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => _clearServerError('name'),
                ),
                const SizedBox(height: MonthraSpacing.x4),
                EmailField(
                  controller: _email,
                  serverError: l10n.serverFieldError(
                    problem,
                    'email',
                    max: AuthLimits.emailMax,
                    email: true,
                  ),
                  onChanged: (_) => _clearServerError('email'),
                ),
                const SizedBox(height: MonthraSpacing.x4),
                PasswordField(
                  controller: _password,
                  isNew: true,
                  serverError: l10n.serverFieldError(
                    problem,
                    'password',
                    min: AuthLimits.passwordMin,
                    max: AuthLimits.passwordMax,
                  ),
                  onChanged: (_) => _clearServerError('password'),
                  onSubmitted: (_) => unawaited(_submit()),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: MonthraSpacing.x6),
        ShadButton(
          enabled: !_busy,
          onPressed: _submit,
          child: ButtonLabel(l10n.authRegisterButton),
        ),
        const SizedBox(height: MonthraSpacing.x6),
        AuthSwitchLink(
          text: l10n.authHaveAccount,
          link: l10n.authSignInTitle,
          onPressed: () => context.go(AppRoutes.login),
        ),
      ],
    );
  }

  Widget _sentView(BuildContext context, String email) {
    final l10n = context.l10n;
    final error = _error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthHeading(
          title: l10n.authCheckInboxTitle,
          subtitle: l10n.authCheckInboxMessage(email),
        ),
        if (error != null) ...[
          FormAlert.error(l10n.apiError(error)),
          const SizedBox(height: MonthraSpacing.x6),
        ] else if (_resent) ...[
          FormAlert(
            message: l10n.authVerificationSent(email),
            icon: LucideIcons.mailCheck,
          ),
          const SizedBox(height: MonthraSpacing.x6),
        ],
        ValueListenableBuilder(
          valueListenable: _resendWait,
          builder: (context, seconds, _) => ShadButton.outline(
            enabled: !_busy && seconds == 0,
            onPressed: _resend,
            leading: const Icon(LucideIcons.mail),
            child: ButtonLabel(
              seconds > 0
                  ? l10n.authResendIn(seconds)
                  : l10n.authResendVerification,
            ),
          ),
        ),
        const SizedBox(height: MonthraSpacing.x4),
        Center(
          child: ShadButton.link(
            onPressed: () => context.go(AppRoutes.login),
            leading: const Icon(LucideIcons.arrowLeft),
            child: ButtonLabel(l10n.authBackToSignIn),
          ),
        ),
      ],
    );
  }
}
