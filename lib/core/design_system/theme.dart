import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/tokens/colors.dart';
import 'package:monthra/core/design_system/tokens/density.dart';
import 'package:monthra/core/design_system/tokens/radii.dart';
import 'package:monthra/core/design_system/tokens/shadows.dart';
import 'package:monthra/core/design_system/tokens/spacing.dart';
import 'package:monthra/core/design_system/tokens/typography.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// How much of the destructive red tints its button under the pointer.
const double destructiveHoverAlpha = 0.08;

/// The shadcn theme of [brightness], built from the Monthra tokens. Both
/// brightnesses share every size; only the color roles differ. Buttons are
/// drawn at 34 px everywhere (a `MonthraTapTarget` gives them the touch
/// target); [density] sets the fields' height: 44 px for touch, 34 on a
/// desktop layout (`MonthraDensity.forWidth` picks it from the window).
ShadThemeData monthraTheme(
  Brightness brightness, {
  MonthraDensity density = MonthraDensity.touch,
}) {
  final scheme = switch (brightness) {
    Brightness.light => MonthraColorSchemes.light,
    Brightness.dark => MonthraColorSchemes.dark,
  };
  const control = MonthraLayout.controlHeight;
  final field = density.fieldHeight;
  // The label row is the tap area of a switch or checkbox: its 20 px line
  // plus this above and below is a whole field.
  final labelPadding = EdgeInsetsDirectional.only(
    start: MonthraSpacing.x2,
    top: (field - 20) / 2,
    bottom: (field - 20) / 2,
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
    // Red only as a signal: the label and a hairline, no fill.
    destructiveButtonTheme: ShadButtonTheme(
      backgroundColor: const Color(0x00000000),
      hoverBackgroundColor: scheme.destructive.withValues(
        alpha: destructiveHoverAlpha,
      ),
      foregroundColor: scheme.destructive,
      hoverForegroundColor: scheme.destructive,
      decoration: ShadDecoration(
        border: ShadBorder.all(
          color: scheme.destructiveBorder,
          radius: MonthraRadii.smAll,
          width: 1,
        ),
      ),
    ),
    // Cards: the lifted surface, a hairline and no shadow.
    cardTheme: const ShadCardTheme(
      padding: EdgeInsets.all(MonthraSpacing.x5),
      radius: MonthraRadii.lgAll,
      shadows: MonthraShadows.none,
    ),
    buttonSizesTheme: const ShadButtonSizesTheme(
      regular: ShadButtonSizeTheme(
        height: control,
        padding: EdgeInsets.symmetric(horizontal: MonthraSpacing.x3 + 2),
      ),
      sm: ShadButtonSizeTheme(
        height: control - 4,
        padding: EdgeInsets.symmetric(horizontal: MonthraSpacing.x2 + 2),
      ),
      lg: ShadButtonSizeTheme(
        height: control + 4,
        padding: EdgeInsets.symmetric(horizontal: MonthraSpacing.x5),
      ),
      icon: ShadButtonSizeTheme(
        height: control,
        width: control,
        padding: EdgeInsets.zero,
      ),
    ),
    inputTheme: ShadInputTheme(constraints: BoxConstraints(minHeight: field)),
    // 20 px of text + the padding above and below + the border: a field.
    selectTheme: ShadSelectTheme(
      padding: EdgeInsets.symmetric(
        horizontal: MonthraSpacing.x3,
        vertical: (field - 22) / 2,
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
