import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/core/forms/countdown.dart';
import 'package:monthra/core/forms/fields.dart';
import 'package:monthra/core/forms/form_alert.dart';
import 'package:monthra/core/forms/second_factor_field.dart';
import 'package:monthra/core/network/api_error_text.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/core/network/api_problem.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// The password asked again before a sensitive change and, with [askCode],
/// a code from the authenticator app or a recovery code. [onSubmit] sends
/// them and throws the `ApiException` of a refusal:
///
/// - a wrong password shows under its field, selected so typing replaces
///   it; a wrong code empties the code field, with an alert above;
/// - both count toward the sign-in lockout of the address, so a `429`
///   holds the button for the wait asked;
/// - anything else shows in the alert.
class StepUpForm extends StatefulWidget {
  const new({
    required this.submitLabel,
    required this.onSubmit,
    this.askCode = true,
    this.destructive = false,
    super.key,
  });

  final String submitLabel;

  /// Gets the password and the code (empty without [askCode]).
  final Future<void> Function(String password, String code) onSubmit;
  final bool askCode;
  final bool destructive;

  @override
  State<StepUpForm> createState() => _StepUpFormState();
}

class _StepUpFormState extends State<StepUpForm> {
  final _form = GlobalKey<ShadFormState>();
  final _password = TextEditingController();
  final _passwordFocus = FocusNode();
  final _factor = SecondFactorController();
  final _locked = Countdown();

  bool _busy = false;
  ApiException? _error;

  @override
  void dispose() {
    _password.dispose();
    _passwordFocus.dispose();
    _factor.dispose();
    _locked.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_error != null) setState(() => _error = null);
  }

  Future<void> _submit() async {
    if (_busy || _locked.running) return;
    setState(() => _error = null);
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _busy = true);
    try {
      await widget.onSubmit(_password.text, widget.askCode ? _factor.code : '');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
      if (e is ApiProblemException) {
        final wait = e.retryAfter;
        if (e.code == ProblemCode.passwordIncorrect) {
          _password.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _password.text.length,
          );
          _passwordFocus.requestFocus();
        } else if (e.code == ProblemCode.mfaCodeInvalid) {
          _factor.clearAfterRefusal();
        } else if (e.code == ProblemCode.rateLimited &&
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
    final passwordError =
        error is ApiProblemException &&
            error.code == ProblemCode.passwordIncorrect
        ? l10n.errorPasswordIncorrect
        : null;
    final label = ButtonLabel(widget.submitLabel);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (error != null && passwordError == null) ...[
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
                  controller: _password,
                  focusNode: _passwordFocus,
                  autofocus: true,
                  serverError: passwordError,
                  textInputAction: widget.askCode
                      ? TextInputAction.next
                      : TextInputAction.done,
                  onChanged: (_) => _clearError(),
                  onSubmitted: (_) => widget.askCode
                      ? _factor.focusNode.requestFocus()
                      : unawaited(_submit()),
                ),
                if (widget.askCode) ...[
                  const SizedBox(height: MonthraSpacing.x4),
                  SecondFactorField(
                    controller: _factor,
                    autofocus: false,
                    onSubmit: () => unawaited(_submit()),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: MonthraSpacing.x6),
        Wrap(
          spacing: MonthraSpacing.x4,
          runSpacing: MonthraSpacing.x2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ValueListenableBuilder(
              valueListenable: _locked,
              // Read here, so the button wakes up when the wait ends.
              builder: (context, _, _) => widget.destructive
                  ? ShadButton.destructive(
                      enabled: !_busy && !_locked.running,
                      onPressed: _submit,
                      child: label,
                    )
                  : ShadButton(
                      enabled: !_busy && !_locked.running,
                      onPressed: _submit,
                      child: label,
                    ),
            ),
            if (widget.askCode)
              SecondFactorToggle(
                controller: _factor,
                onToggled: () {
                  _clearError();
                  _factor.focusNode.requestFocus();
                },
              ),
          ],
        ),
      ],
    );
  }
}
