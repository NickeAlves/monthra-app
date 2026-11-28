import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/core/forms/validators.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// The height of every field of the account forms: the password field's,
/// whose show/hide button is a full touch target.
const BoxConstraints authFieldConstraints = BoxConstraints(
  minHeight: MonthraLayout.fieldWithButtonHeight,
);

/// An email address field: the email keyboard, no autocorrect, autofill.
class EmailField extends StatelessWidget {
  const new({
    required this.controller,
    this.serverError,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction = TextInputAction.next,
    this.autofocus = false,
    super.key,
  });

  final TextEditingController controller;

  /// What the server said about the field (`422`), shown until it changes.
  final String? serverError;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction textInputAction;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ShadInputFormField(
      id: 'email',
      controller: controller,
      constraints: authFieldConstraints,
      label: Text(l10n.authEmailLabel),
      forceErrorText: serverError,
      validator: l10n.validateEmail,
      keyboardType: TextInputType.emailAddress,
      textInputAction: textInputAction,
      autofillHints: const [AutofillHints.email, AutofillHints.username],
      autocorrect: false,
      enableSuggestions: false,
      autofocus: autofocus,
      maxLength: AuthLimits.emailMax,
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }
}

/// A password field with a show/hide button. [isNew] picks the autofill
/// hint (a password manager offers to generate one) and the help line.
class PasswordField extends StatefulWidget {
  const new({
    required this.controller,
    this.isNew = false,
    this.id = 'password',
    this.label,
    this.serverError,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction = TextInputAction.done,
    this.focusNode,
    this.autofocus = false,
    super.key,
  });

  final TextEditingController controller;
  final bool isNew;

  /// The field's id in its [ShadForm]: unique when a form has two.
  final String id;

  /// "Password" when null.
  final String? label;
  final bool autofocus;

  /// Lets the page bring the cursor back after a failed attempt (Enter
  /// with `done` takes the focus away).
  final FocusNode? focusNode;
  final String? serverError;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction textInputAction;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ShadInputFormField(
      id: widget.id,
      controller: widget.controller,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      constraints: authFieldConstraints,
      label: Text(widget.label ?? l10n.authPasswordLabel),
      description: widget.isNew ? Text(l10n.authNewPasswordHint) : null,
      forceErrorText: widget.serverError,
      validator: widget.isNew
          ? l10n.validateNewPassword
          : l10n.validateCurrentPassword,
      obscureText: !_visible,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      autofillHints: [
        if (widget.isNew) AutofillHints.newPassword else AutofillHints.password,
      ],
      autocorrect: false,
      enableSuggestions: false,
      maxLength: AuthLimits.passwordMax,
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      // The button fills the field's end: a full 44 px target.
      padding: const EdgeInsetsDirectional.only(start: MonthraSpacing.x3),
      trailing: MonthraTapTarget(
        child: ShadIconButton.ghost(
          icon: Icon(
            _visible ? LucideIcons.eyeOff : LucideIcons.eye,
            semanticLabel: _visible
                ? l10n.authHidePassword
                : l10n.authShowPassword,
          ),
          onPressed: () => setState(() => _visible = !_visible),
        ),
      ),
    );
  }
}
