import 'dart:async';

import 'package:flutter/semantics.dart' show SemanticsRole;
import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/components/monthra_confirm.dart';
import 'package:monthra/core/design_system/tokens/breakpoints.dart';
import 'package:monthra/core/design_system/tokens/spacing.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// What a [MonthraFormSheet] says, translated by the caller (core has no
/// strings): the close button and the question asked before changes are
/// thrown away.
typedef MonthraFormSheetLabels = ({
  /// The close button ("Close").
  String close,

  /// "Discard changes?"
  String discardTitle,

  /// "Discard"
  String discard,

  /// "Keep editing"
  String keepEditing,
});

/// Opens a form over the page: a dialog on a tablet or a desktop, a bottom
/// sheet on a phone (over the bar, padded by the keyboard). [builder]
/// returns a [MonthraFormSheet]; the route answers what the form pops
/// (the record it saved), or null when closed.
Future<T?> showMonthraFormSheet<T>(
  BuildContext context, {
  required String barrierLabel,
  required WidgetBuilder builder,
}) {
  final sheet = context.monthraBreakpoint == MonthraBreakpoint.mobile;
  Widget build(BuildContext context) => _FormSheetKind(
    sheet: sheet,
    child: Builder(builder: builder),
  );
  return sheet
      ? showShadSheet<T>(
          context: context,
          side: ShadSheetSide.bottom,
          barrierLabel: barrierLabel,
          useRootNavigator: true,
          builder: build,
        )
      : showShadDialog<T>(
          context: context,
          barrierLabel: barrierLabel,
          builder: build,
        );
}

class _FormSheetKind extends InheritedWidget {
  const new({required this.sheet, required super.child});

  final bool sheet;

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_FormSheetKind>()?.sheet ??
      false;

  @override
  bool updateShouldNotify(_FormSheetKind oldWidget) => sheet != oldWidget.sheet;
}

/// The surface of a form opened with [showMonthraFormSheet]: [title],
/// [description], the form ([child]) and its [actions] (save, cancel),
/// with a close button.
///
/// While [dirty], every way out (the close button, the barrier, Esc, the
/// platform's back) asks before throwing the changes away; while [busy]
/// (a save in flight) none closes it. Saving pops the route itself
/// (`Navigator.pop(context, saved)`), which asks nothing.
class MonthraFormSheet extends StatelessWidget {
  const new({
    required this.title,
    required this.labels,
    required this.child,
    this.description,
    this.actions = const [],
    this.dirty = false,
    this.busy = false,
    super.key,
  });

  final String title;
  final String? description;
  final MonthraFormSheetLabels labels;
  final List<Widget> actions;
  final bool dirty;
  final bool busy;
  final Widget child;

  /// The widest a dialog grows.
  static const double dialogWidth = 520;

  Future<void> _closeAsked(BuildContext context) async {
    if (busy) return;
    final navigator = Navigator.of(context);
    final discard = await showMonthraConfirm(
      context,
      title: labels.discardTitle,
      confirmLabel: labels.discard,
      cancelLabel: labels.keepEditing,
      barrierLabel: labels.close,
      destructive: true,
    );
    if (discard && navigator.mounted) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final sheet = _FormSheetKind.of(context);
    final description = this.description;
    final close = ShadIconButton.ghost(
      width: MonthraLayout.minTouchTarget,
      height: MonthraLayout.minTouchTarget,
      icon: Icon(LucideIcons.x300, size: 16, semanticLabel: labels.close),
      // maybePop, so the guard below hears it (shadcn's own close pops).
      onPressed: busy ? null : () => Navigator.of(context).maybePop(),
    );
    final content = Padding(
      padding: const EdgeInsets.only(top: MonthraSpacing.x4),
      child: child,
    );
    final Widget surface;
    if (sheet) {
      surface = ShadSheet(
        title: Text(title),
        description: description == null ? null : Text(description),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        closeIcon: close,
        // The title stays while a long form scrolls under it.
        titlePinned: true,
        descriptionPinned: true,
        actions: actions,
        child: content,
      );
    } else {
      surface = ShadDialog(
        title: Text(title),
        description: description == null ? null : Text(description),
        constraints: const BoxConstraints(maxWidth: dialogWidth),
        closeIcon: close,
        titlePinned: true,
        descriptionPinned: true,
        actions: actions,
        child: content,
      );
    }
    return PopScope<Object?>(
      canPop: !dirty && !busy,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !busy) unawaited(_closeAsked(context));
      },
      child: Semantics(
        role: SemanticsRole.dialog,
        scopesRoute: true,
        namesRoute: true,
        explicitChildNodes: true,
        label: title,
        // A tap on a control that takes no focus (a switch) after a text
        // field drops the focus above the route, out of reach of Esc:
        // bring it back into the route (a select's menu keeps its own).
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerUp: (_) => WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            final scope = FocusScope.of(context);
            final primary = FocusManager.instance.primaryFocus;
            if (primary != null && scope.ancestors.contains(primary)) {
              scope.requestFocus();
            }
          }),
          child: surface,
        ),
      ),
    );
  }
}
