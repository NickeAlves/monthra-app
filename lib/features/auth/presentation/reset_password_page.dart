import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:monthra/app/router.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/core/forms/fields.dart';
import 'package:monthra/core/forms/form_alert.dart';
import 'package:monthra/core/forms/validators.dart';
import 'package:monthra/core/network/api_error_text.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/core/network/api_problem.dart';
import 'package:monthra/features/auth/application/auth_controller.dart';
import 'package:monthra/features/auth/application/auth_state.dart';
import 'package:monthra/features/auth/data/auth_api.dart';
import 'package:monthra/features/auth/presentation/auth_layout.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Opened from the reset email (`/reset-password#token=…`): a new password.
/// The server signs out every session, so the app does too and sends the
/// person to the sign-in page.
class ResetPasswordPage extends ConsumerStatefulWidget {
  const new({required this.token, super.key});

  /// The link's token; null when the link had none.
  final String? token;

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _form = GlobalKey<ShadFormState>();
  final _password = TextEditingController();

  /// Read once: the address bar loses it right after the first frame.
  late final String? _token = widget.token;

  bool _busy = false;
  bool _linkDead = false;
  ApiException? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) dropLinkFragment(context);
    });
  }

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final token = _token;
    if (_busy || token == null) return;
    setState(() => _error = null);
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(authApiProvider)
          .resetPassword(token: token, password: _password.text);
      TextInput.finishAutofillContext();
      _password.clear();
      // Every session ended, this one included.
      await ref
          .read(authControllerProvider.notifier)
          .sessionEnded(AuthNotice.passwordReset);
      if (mounted) context.go(AppRoutes.login);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        if (e is ApiProblemException && e.code == ProblemCode.tokenInvalid) {
          _linkDead = true;
        } else {
          _error = e;
        }
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (_token == null || _linkDead) {
      return AuthLayout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthHeading(
              title: l10n.authLinkInvalidTitle,
              subtitle: l10n.authResetLinkInvalidMessage,
            ),
            ShadButton(
              onPressed: () => context.go(AppRoutes.forgotPassword),
              child: ButtonLabel(l10n.authRequestNewLink),
            ),
          ],
        ),
      );
    }
    final error = _error;
    final problem = switch (error) {
      final ApiProblemException p => p.problem,
      _ => null,
    };
    return AuthLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthHeading(
            title: l10n.authResetTitle,
            subtitle: l10n.authResetSubtitle,
          ),
          if (error != null) ...[
            FormAlert.error(l10n.apiError(error)),
            const SizedBox(height: MonthraSpacing.x6),
          ],
          ShadForm(
            key: _form,
            child: AutofillGroup(
              onDisposeAction: AutofillContextAction.cancel,
              child: PasswordField(
                controller: _password,
                isNew: true,
                serverError: l10n.serverFieldError(
                  problem,
                  'password',
                  min: AuthLimits.passwordMin,
                  max: AuthLimits.passwordMax,
                ),
                onChanged: (_) {
                  if (problem != null) setState(() => _error = null);
                },
                onSubmitted: (_) => unawaited(_submit()),
              ),
            ),
          ),
          const SizedBox(height: MonthraSpacing.x6),
          ShadButton(
            enabled: !_busy,
            onPressed: _submit,
            child: ButtonLabel(l10n.authResetButton),
          ),
        ],
      ),
    );
  }
}
