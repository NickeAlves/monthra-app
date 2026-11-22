import 'package:flutter/semantics.dart' show SemanticsRole;
import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/components/button_label.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Asks before an action that is hard to take back (signing other devices
/// out, leaving recovery codes unsaved): [title], [description], and two
/// buttons, [cancelLabel] (first, the safe way out) and [confirmLabel]
/// (destructive when [destructive]). True only when confirmed: Esc, the
/// barrier (labeled [barrierLabel]) and cancel all answer false. Labels
/// come translated from the caller (core has no strings).
Future<bool> showMonthraConfirm(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  required String cancelLabel,
  required String barrierLabel,
  String? description,
  bool destructive = false,
}) async {
  final confirmed = await showShadDialog<bool>(
    context: context,
    barrierLabel: barrierLabel,
    builder: (context) {
      void confirm() => Navigator.of(context).pop(true);
      void cancel() => Navigator.of(context).pop(false);
      return Semantics(
        role: SemanticsRole.alertDialog,
        scopesRoute: true,
        namesRoute: true,
        explicitChildNodes: true,
        label: title,
        child: ShadDialog.alert(
          title: Text(title),
          description: description == null ? null : Text(description),
          actions: [
            ShadButton.outline(
              onPressed: cancel,
              child: ButtonLabel(cancelLabel),
            ),
            if (destructive)
              ShadButton.destructive(
                onPressed: confirm,
                child: ButtonLabel(confirmLabel),
              )
            else
              ShadButton(onPressed: confirm, child: ButtonLabel(confirmLabel)),
          ],
        ),
      );
    },
  );
  return confirmed ?? false;
}
