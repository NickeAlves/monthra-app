import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/tokens/breakpoints.dart';
import 'package:monthra/core/design_system/tokens/spacing.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// How long a toast stays: an error longer, to be read.
abstract final class MonthraToastDuration {
  static const Duration info = Duration(seconds: 4);
  static const Duration error = Duration(seconds: 6);
}

/// Shows a short message over the app ([ShadToaster]): [title], and
/// [description] below. Read out by assistive technologies when it
/// appears; its close button (labeled [closeLabel], translated by the
/// caller: core has no strings) is always there and takes a whole touch
/// target. On a phone it shows on top, clear of the bottom bar.
void showMonthraToast(
  BuildContext context, {
  required String title,
  required String closeLabel,
  String? description,
  bool destructive = false,
}) {
  final mobile = context.monthraBreakpoint == MonthraBreakpoint.mobile;
  final close = Builder(
    builder: (context) {
      final scheme = ShadTheme.of(context).colorScheme;
      // On the toast's own background: the destructive one is red.
      final color = destructive
          ? scheme.destructiveForeground
          : scheme.foreground;
      return ShadIconButton.ghost(
        width: MonthraLayout.minTouchTarget,
        height: MonthraLayout.minTouchTarget,
        foregroundColor: color,
        hoverForegroundColor: color,
        pressedForegroundColor: color,
        hoverBackgroundColor: color.withValues(alpha: 0.1),
        icon: Icon(LucideIcons.x, size: 16, semanticLabel: closeLabel),
        onPressed: () => ShadToaster.of(context).hide(),
      );
    },
  );
  // One announcement with both lines; the texts below are not read again.
  final announced = Semantics(
    liveRegion: true,
    container: true,
    label: description == null ? title : '$title\n$description',
    child: ExcludeSemantics(child: Text(title)),
  );
  final body = description == null
      ? null
      : ExcludeSemantics(child: Text(description));
  final alignment = mobile ? Alignment.topCenter : Alignment.bottomRight;
  const padding = EdgeInsetsDirectional.fromSTEB(
    MonthraSpacing.x4,
    MonthraSpacing.x4,
    MonthraLayout.minTouchTarget + MonthraSpacing.x3,
    MonthraSpacing.x4,
  );
  final position = ShadPosition.directional(
    top: MonthraSpacing.x1,
    end: MonthraSpacing.x1,
    textDirection: Directionality.of(context),
  );
  final duration = destructive
      ? MonthraToastDuration.error
      : MonthraToastDuration.info;
  final toast = destructive
      ? ShadToast.destructive(
          title: announced,
          description: body,
          closeIcon: close,
          closeIconPosition: position,
          showCloseIconOnlyWhenHovered: false,
          padding: padding,
          alignment: alignment,
          duration: duration,
        )
      : ShadToast(
          title: announced,
          description: body,
          closeIcon: close,
          closeIconPosition: position,
          showCloseIconOnlyWhenHovered: false,
          padding: padding,
          alignment: alignment,
          duration: duration,
        );
  ShadToaster.of(context).show(toast);
}
