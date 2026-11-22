import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/core/forms/fields.dart';
import 'package:monthra/core/forms/validators.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// The state of a [SecondFactorField]: what was typed in each mode and
/// which one shows.
class SecondFactorController extends ChangeNotifier {
  final TextEditingController totp = TextEditingController();
  final TextEditingController recovery = TextEditingController();

  /// The field's focus, to bring the cursor back after a refusal.
  final FocusNode focusNode = FocusNode();

  bool _useRecovery = false;

  /// A recovery code instead of the authenticator app's code.
  bool get useRecovery => _useRecovery;

  /// What to send: the shown field's text, trimmed.
  String get code => (_useRecovery ? recovery : totp).text.trim();

  /// Switches between the app's code and a recovery code.
  void toggle() {
    _useRecovery = !_useRecovery;
    notifyListeners();
  }

  /// After a wrong code: empties the shown field and focuses it.
  void clearAfterRefusal() {
    (_useRecovery ? recovery : totp).clear();
    focusNode.requestFocus();
  }

  @override
  void dispose() {
    totp.dispose();
    recovery.dispose();
    focusNode.dispose();
    super.dispose();
  }
}

/// The second factor of a sign-in or of a sensitive change: a 6-digit code
/// from the authenticator app or, after [SecondFactorToggle], a recovery
/// code. One field (not one box per digit), so the platform's one-time-code
/// autofill and screen readers handle it as one value. The sixth digit
/// sends it ([onSubmit]).
class SecondFactorField extends StatelessWidget {
  const new({
    required this.controller,
    required this.onSubmit,
    this.serverError,
    this.autofocus = true,
    super.key,
  });

  final SecondFactorController controller;
  final VoidCallback onSubmit;

  /// What the server said about the code, shown until it changes.
  final String? serverError;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final l10n = context.l10n;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => controller.useRecovery
          ? ShadInputFormField(
              key: const ValueKey('recovery'),
              id: 'code',
              controller: controller.recovery,
              constraints: authFieldConstraints,
              focusNode: controller.focusNode,
              autofocus: autofocus,
              label: Text(l10n.authMfaRecoveryLabel),
              forceErrorText: serverError,
              validator: l10n.validateRequired,
              autocorrect: false,
              enableSuggestions: false,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => onSubmit(),
            )
          : ShadInputFormField(
              key: const ValueKey('totp'),
              id: 'code',
              controller: controller.totp,
              constraints: authFieldConstraints,
              focusNode: controller.focusNode,
              autofocus: autofocus,
              label: Text(l10n.authMfaCodeLabel),
              forceErrorText: serverError,
              validator: (value) => value.length == AuthLimits.mfaCodeLength
                  ? null
                  : l10n.errorMfaCodeFormat,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.oneTimeCode],
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(AuthLimits.mfaCodeLength),
              ],
              // Tabular digits, as amounts are written.
              style: theme.textTheme.amount.copyWith(
                color: theme.colorScheme.foreground,
              ),
              // The sixth digit sends it: no extra tap.
              onChanged: (value) {
                if (value.length == AuthLimits.mfaCodeLength) onSubmit();
              },
              onSubmitted: (_) => onSubmit(),
            ),
    );
  }
}

/// The link that switches a [SecondFactorField] between the app's code and
/// a recovery code, then puts the cursor in the field it shows (once that
/// field is built: the other one is gone); [onToggled] runs after (clear an
/// error, reset the form).
class SecondFactorToggle extends StatelessWidget {
  const new({required this.controller, this.onToggled, super.key});

  final SecondFactorController controller;
  final VoidCallback? onToggled;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => ShadButton.link(
        onPressed: () {
          controller.toggle();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (controller.focusNode.context != null) {
              controller.focusNode.requestFocus();
            }
          });
          onToggled?.call();
        },
        child: ButtonLabel(
          controller.useRecovery ? l10n.authMfaUseApp : l10n.authMfaUseRecovery,
        ),
      ),
    );
  }
}
