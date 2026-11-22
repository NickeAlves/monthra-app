import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:monthra/app/routes.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/core/forms/countdown.dart';
import 'package:monthra/core/forms/fields.dart';
import 'package:monthra/core/forms/form_alert.dart';
import 'package:monthra/core/forms/validators.dart';
import 'package:monthra/core/network/api_error_text.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/core/network/api_problem.dart';
import 'package:monthra/features/settings/application/sessions_controller.dart';
import 'package:monthra/features/settings/data/me_api.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Changes the password (`POST /me/password`): the current one, then the
/// new one. The server signs out the other sessions; this one stays.
///
/// A wrong current password shows under its field and counts toward the
/// sign-in lockout of the address (so the button waits out a `429`); the
/// server's rules for the new one (length, a breached password) show under
/// the new field.
class ChangePasswordPage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _form = GlobalKey<ShadFormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _currentFocus = FocusNode();
  final _locked = Countdown();

  bool _busy = false;
  ApiException? _error;

  ApiProblemException? get _problem => switch (_error) {
    final ApiProblemException p => p,
    _ => null,
  };

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _currentFocus.dispose();
    _locked.dispose();
    super.dispose();
  }

  void _back() => context.go(AppRoutes.settings);

  void _clearError() {
    if (_error != null) setState(() => _error = null);
  }

  Future<void> _submit() async {
    if (_busy || _locked.running) return;
    setState(() => _error = null);
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _busy = true);
    final l10n = context.l10n;
    try {
      await ref
          .read(meApiProvider)
          .changePassword(current: _current.text, next: _next.text);
      if (!mounted) return;
      // A password manager may offer to save the new one.
      TextInput.finishAutofillContext();
      ref.invalidate(sessionsControllerProvider);
      showMonthraToast(
        context,
        title: l10n.passwordChanged,
        description: l10n.passwordChangedDescription,
        closeLabel: l10n.appClose,
      );
      _back();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
      if (e is ApiProblemException) {
        if (e.code == ProblemCode.passwordIncorrect) {
          // Selected, so typing replaces it (an emptied field would read
          // "required" over the server's word).
          _current.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _current.text.length,
          );
          _currentFocus.requestFocus();
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final error = _error;
    final problem = _problem;
    final currentError = problem?.code == ProblemCode.passwordIncorrect
        ? l10n.errorPasswordIncorrect
        : null;
    final newError = l10n.serverFieldError(
      problem?.problem,
      'newPassword',
      min: AuthLimits.passwordMin,
      max: AuthLimits.passwordMax,
    );
    final alert = error != null && currentError == null && newError == null;
    return MonthraPage(
      title: l10n.settingsPasswordChange,
      description: l10n.passwordPageDescription,
      back: MonthraPageBack(label: l10n.navSettings, onPressed: _back),
      maxWidth: MonthraLayout.maxFormWidth,
      child: MonthraCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (alert) ...[
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
                    PasswordField(
                      id: 'currentPassword',
                      label: l10n.passwordCurrentLabel,
                      controller: _current,
                      focusNode: _currentFocus,
                      autofocus: true,
                      serverError: currentError,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => _clearError(),
                    ),
                    const SizedBox(height: MonthraSpacing.x4),
                    PasswordField(
                      id: 'newPassword',
                      label: l10n.passwordNewLabel,
                      isNew: true,
                      controller: _next,
                      serverError: newError,
                      onChanged: (_) => _clearError(),
                      onSubmitted: (_) => unawaited(_submit()),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: MonthraSpacing.x6),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: ValueListenableBuilder(
                valueListenable: _locked,
                builder: (context, _, _) => ShadButton(
                  enabled: !_busy && !_locked.running,
                  onPressed: _submit,
                  child: ButtonLabel(l10n.passwordSubmit),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
