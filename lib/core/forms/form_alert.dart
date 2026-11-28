import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/core/network/api_error_text.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// A message above a form: an error ([FormAlert.error]) or a notice, read
/// out by screen readers when it appears.
class FormAlert extends StatelessWidget {
  const new({
    required this.message,
    this.reference,
    this.destructive = false,
    this.icon = LucideIcons.info300,
    this.action,
    super.key,
  });

  /// An [ApiErrorMessage] as a destructive alert.
  factory error(ApiErrorMessage error, {Widget? action, Key? key}) => FormAlert(
    message: error.message,
    reference: error.reference,
    destructive: true,
    icon: LucideIcons.circleAlert300,
    action: action,
    key: key,
  );

  final String message;

  /// The request id to quote to support, under the message.
  final String? reference;
  final bool destructive;
  final IconData icon;

  /// A button under the message (resend the email, say).
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final reference = this.reference;
    final action = this.action;
    final description = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (reference != null)
          Padding(
            padding: const EdgeInsets.only(top: MonthraSpacing.x1),
            child: Text(context.l10n.errorReference(reference)),
          ),
        if (action != null)
          Padding(
            padding: const EdgeInsets.only(top: MonthraSpacing.x2),
            child: action,
          ),
      ],
    );
    final hasDescription = reference != null || action != null;
    return Semantics(
      liveRegion: true,
      container: true,
      child: destructive
          ? ShadAlert.destructive(
              icon: Icon(icon),
              title: Text(message),
              description: hasDescription ? description : null,
            )
          : ShadAlert(
              icon: Icon(icon),
              title: Text(message),
              description: hasDescription ? description : null,
            ),
    );
  }
}
