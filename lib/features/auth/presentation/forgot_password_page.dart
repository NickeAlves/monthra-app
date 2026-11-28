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
import 'package:monthra/features/auth/data/auth_api.dart';
import 'package:monthra/features/auth/presentation/auth_layout.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Asks for a reset link. The answer never says whether the address has an
/// account, and neither does the page.
class ForgotPasswordPage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _form = GlobalKey<ShadFormState>();
  final _email = TextEditingController();

  bool _busy = false;
  ApiException? _error;
  String? _sentTo;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() => _error = null);
    if (!(_form.currentState?.validate() ?? false)) return;
    final email = _email.text.trim();
    setState(() => _busy = true);
    try {
      await ref.read(authApiProvider).forgotPassword(email);
      if (mounted) setState(() => _sentTo = email);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final error = _error;
    final sentTo = _sentTo;
    final problem = switch (error) {
      final ApiProblemException p => p.problem,
      _ => null,
    };
    final back = Center(
      child: MonthraTapTarget(
        child: ShadButton.link(
          onPressed: () => context.go(AppRoutes.login),
          leading: const Icon(LucideIcons.arrowLeft),
          child: ButtonLabel(l10n.authBackToSignIn),
        ),
      ),
    );
    if (sentTo != null) {
      return AuthLayout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthHeading(
              title: l10n.authCheckInboxTitle,
              subtitle: l10n.authForgotSentMessage(sentTo),
            ),
            back,
          ],
        ),
      );
    }
    return AuthLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthHeading(
            title: l10n.authForgotTitle,
            subtitle: l10n.authForgotSubtitle,
          ),
          if (error != null) ...[
            FormAlert.error(l10n.apiError(error)),
            const SizedBox(height: MonthraSpacing.x6),
          ],
          ShadForm(
            key: _form,
            child: AutofillGroup(
              onDisposeAction: AutofillContextAction.cancel,
              child: EmailField(
                controller: _email,
                autofocus: true,
                textInputAction: TextInputAction.send,
                serverError: l10n.serverFieldError(
                  problem,
                  'email',
                  max: AuthLimits.emailMax,
                  email: true,
                ),
                onSubmitted: (_) => unawaited(_submit()),
              ),
            ),
          ),
          const SizedBox(height: MonthraSpacing.x6),
          MonthraTapTarget(
            child: ShadButton(
              enabled: !_busy,
              onPressed: _submit,
              child: ButtonLabel(l10n.authForgotButton),
            ),
          ),
          const SizedBox(height: MonthraSpacing.x4),
          back,
        ],
      ),
    );
  }
}
