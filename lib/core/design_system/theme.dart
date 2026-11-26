import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/tokens/colors.dart';
import 'package:monthra/core/design_system/tokens/density.dart';
import 'package:monthra/core/design_system/tokens/radii.dart';
import 'package:monthra/core/design_system/tokens/shadows.dart';
import 'package:monthra/core/design_system/tokens/spacing.dart';
import 'package:monthra/core/design_system/tokens/typography.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// The shadcn theme of [brightness], built from the Monthra tokens. Both
/// brightnesses share every size; only the color roles differ. [density]
/// sets the controls' height: 44 px for touch, 36 on a desktop layout
/// (`MonthraDensity.forWidth` picks it from the window).
ShadThemeData monthraTheme(
  Brightness brightness, {
  MonthraDensity density = MonthraDensity.touch,
}) {
  final scheme = switch (brightness) {
    Brightness.light => MonthraColorSchemes.light,
    Brightness.dark => MonthraColorSchemes.dark,
  };
  final control = density.controlHeight;
  final touch = density == MonthraDensity.touch;
  // The label row is the tap area of a switch or checkbox: its 20 px line
  // plus this above and below is a whole control.
  final labelPadding = EdgeInsetsDirectional.only(
    start: MonthraSpacing.x2,
    top: (control - 20) / 2,
    bottom: (control - 20) / 2,
  );
  return ShadThemeData(
    brightness: brightness,
    colorScheme: scheme,
    textTheme: MonthraTypography.textTheme,
    radius: MonthraRadii.smAll,
    // shadcn paints outline, ghost and link buttons in `primary`; links take
    // the green, the rest the text color.
    outlineButtonTheme: ShadButtonTheme(foregroundColor: scheme.foreground),
    ghostButtonTheme: ShadButtonTheme(foregroundColor: scheme.foreground),
    linkButtonTheme: ShadButtonTheme(
      foregroundColor: scheme.accentText,
      hoverForegroundColor: scheme.accentText,
    ),
    // Cards: the lifted surface, a hairline and no shadow.
    cardTheme: const ShadCardTheme(
      padding: EdgeInsets.all(MonthraSpacing.x5),
      radius: MonthraRadii.lgAll,
      shadows: MonthraShadows.none,
    ),
    buttonSizesTheme: ShadButtonSizesTheme(
      regular: ShadButtonSizeTheme(
        height: control,
        padding: EdgeInsets.symmetric(
          horizontal: touch ? MonthraSpacing.x4 : MonthraSpacing.x3 + 2,
        ),
      ),
      // Pointer layouts only: under a touch target.
      sm: ShadButtonSizeTheme(
        height: touch ? 36 : 30,
        padding: const EdgeInsets.symmetric(horizontal: MonthraSpacing.x3),
      ),
      lg: ShadButtonSizeTheme(
        height: control + 4,
        padding: const EdgeInsets.symmetric(horizontal: MonthraSpacing.x6),
      ),
      icon: ShadButtonSizeTheme(
        height: control,
        width: control,
        padding: EdgeInsets.zero,
      ),
    ),
    inputTheme: ShadInputTheme(constraints: BoxConstraints(minHeight: control)),
    // 20 px of text + the padding above and below + the border: a control.
    selectTheme: ShadSelectTheme(
      padding: EdgeInsets.symmetric(
        horizontal: MonthraSpacing.x3,
        vertical: (control - 22) / 2,
      ),
    ),
    // "On" reads green: a checked box, a switch that is on.
    switchTheme: ShadSwitchTheme(
      padding: labelPadding,
      checkedTrackColor: scheme.accentText,
    ),
    checkboxTheme: ShadCheckboxTheme(
      padding: labelPadding,
      color: scheme.accentText,
      // The empty box keeps 3:1 (WCAG 1.4.11) in the muted text color.
      decoration: ShadDecoration(
        border: ShadBorder.all(
          color: scheme.mutedForeground,
          radius: MonthraRadii.xsAll,
          width: 1,
        ),
      ),
    ),
    // A thin bar on the muted track (a card's limit, a budget).
    progressTheme: ShadProgressTheme(
      minHeight: 6,
      backgroundColor: scheme.muted,
      borderRadius: MonthraRadii.pillAll,
      innerBorderRadius: MonthraRadii.pillAll,
    ),
    // Dialogs, sheets and toasts lift off the page on the popover surface.
    primaryDialogTheme: ShadDialogTheme(
      radius: MonthraRadii.lgAll,
      backgroundColor: scheme.popover,
    ),
    alertDialogTheme: ShadDialogTheme(
      radius: MonthraRadii.lgAll,
      backgroundColor: scheme.popover,
    ),
    sheetTheme: ShadSheetTheme(
      radius: MonthraRadii.lgAll,
      backgroundColor: scheme.popover,
    ),
    primaryToastTheme: ShadToastTheme(
      radius: MonthraRadii.mdAll,
      backgroundColor: scheme.popover,
    ),
    destructiveToastTheme: const ShadToastTheme(radius: MonthraRadii.mdAll),
  );
}
