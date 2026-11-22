import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:monthra/app/router.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/core/forms/countdown.dart';
import 'package:monthra/core/forms/form_alert.dart';
import 'package:monthra/core/forms/second_factor_field.dart';
import 'package:monthra/core/network/api_error_text.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/core/network/api_problem.dart';
import 'package:monthra/features/auth/application/auth_controller.dart';
import 'package:monthra/features/auth/presentation/auth_layout.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// The second sign-in step: a 6-digit code from the authenticator app, or
/// a recovery code ([SecondFactorField]).
class MfaPage extends ConsumerStatefulWidget {
  const new({this.from, super.key});

  final String? from;

  @override
  ConsumerState<MfaPage> createState() => _MfaPageState();
}

class _MfaPageState extends ConsumerState<MfaPage> {
  final _form = GlobalKey<ShadFormState>();
  final _factor = SecondFactorController();
  final _locked = Countdown();

  bool _busy = false;
  ApiException? _error;

  @override
  void dispose() {
    _factor.dispose();
    _locked.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || _locked.running) return;
    if (!(_form.currentState?.validate() ?? false)) return;
    final code = _factor.code;
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
        if (e.code == ProblemCode.mfaCodeInvalid) _factor.clearAfterRefusal();
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

  void _onToggled() => setState(() {
    _error = null;
    _form.currentState?.reset();
  });

  void _back() {
    ref.read(authControllerProvider.notifier).cancelMfa();
    context.go(AppRoutes.withFrom(AppRoutes.login, widget.from));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final error = _error;
    return AuthLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthHeading(
            title: l10n.authMfaTitle,
            subtitle: _factor.useRecovery
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
              child: SecondFactorField(
                controller: _factor,
                onSubmit: () => unawaited(_submit()),
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
            child: SecondFactorToggle(
              controller: _factor,
              onToggled: _onToggled,
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
