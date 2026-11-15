import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/tokens/colors.dart';
import 'package:monthra/core/design_system/tokens/radii.dart';
import 'package:monthra/core/design_system/tokens/shadows.dart';
import 'package:monthra/core/design_system/tokens/spacing.dart';
import 'package:monthra/core/design_system/tokens/typography.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

const _labelPadding = EdgeInsetsDirectional.only(
  start: MonthraSpacing.x2,
  top: MonthraSpacing.x3,
  bottom: MonthraSpacing.x3,
);

/// The shadcn theme of [brightness], built from the Monthra tokens. Both
/// brightnesses share every size; only the color roles differ.
ShadThemeData monthraTheme(Brightness brightness) {
  final scheme = switch (brightness) {
    Brightness.light => MonthraColorSchemes.light,
    Brightness.dark => MonthraColorSchemes.dark,
  };
  const touch = MonthraLayout.minTouchTarget;
  return ShadThemeData(
    brightness: brightness,
    colorScheme: scheme,
    textTheme: MonthraTypography.textTheme,
    radius: MonthraRadii.mdAll,
    // shadcn paints outline, ghost and link buttons in `primary`, a neutral
    // there; with the brand green as primary that text would fall to 2.9:1
    // on the dark background.
    outlineButtonTheme: ShadButtonTheme(foregroundColor: scheme.foreground),
    ghostButtonTheme: ShadButtonTheme(foregroundColor: scheme.foreground),
    linkButtonTheme: ShadButtonTheme(
      foregroundColor: scheme.accentText,
      hoverForegroundColor: scheme.accentText,
    ),
    cardTheme: ShadCardTheme(
      padding: const EdgeInsets.all(MonthraSpacing.x6),
      radius: MonthraRadii.lgAll,
      shadows: MonthraShadows.card(brightness),
    ),
    // Every control is at least 44 px tall: the same sizes on touch and
    // pointer screens (§4.4).
    buttonSizesTheme: const ShadButtonSizesTheme(
      regular: ShadButtonSizeTheme(
        height: touch,
        padding: EdgeInsets.symmetric(horizontal: MonthraSpacing.x4),
      ),
      sm: ShadButtonSizeTheme(
        height: 36,
        padding: EdgeInsets.symmetric(horizontal: MonthraSpacing.x3),
      ),
      lg: ShadButtonSizeTheme(
        height: 48,
        padding: EdgeInsets.symmetric(horizontal: MonthraSpacing.x8),
      ),
      icon: ShadButtonSizeTheme(
        height: touch,
        width: touch,
        padding: EdgeInsets.zero,
      ),
    ),
    inputTheme: const ShadInputTheme(
      constraints: BoxConstraints(minHeight: touch),
    ),
    // 20 px of text + 2 x 11 + the border: 44.
    selectTheme: const ShadSelectTheme(
      padding: EdgeInsets.symmetric(
        horizontal: MonthraSpacing.x3,
        vertical: 11,
      ),
    ),
    // The label row is the tap area of a switch or checkbox: 12 px above and
    // below its 20 px line make it 44.
    switchTheme: const ShadSwitchTheme(padding: _labelPadding),
    checkboxTheme: ShadCheckboxTheme(
      padding: _labelPadding,
      decoration: ShadDecoration(
        border: ShadBorder.all(
          color: scheme.primary,
          radius: MonthraRadii.xsAll,
          width: 1,
        ),
      ),
    ),
    primaryDialogTheme: const ShadDialogTheme(radius: MonthraRadii.lgAll),
    alertDialogTheme: const ShadDialogTheme(radius: MonthraRadii.lgAll),
    sheetTheme: const ShadSheetTheme(radius: MonthraRadii.lgAll),
    primaryToastTheme: const ShadToastTheme(radius: MonthraRadii.mdAll),
    destructiveToastTheme: const ShadToastTheme(radius: MonthraRadii.mdAll),
  );
}
