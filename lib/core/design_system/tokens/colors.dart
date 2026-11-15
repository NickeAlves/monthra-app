import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/tokens/palette.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Keys of the Monthra roles kept in [ShadColorScheme.custom], so they
/// animate with the theme like the built-in roles.
abstract final class _Role {
  static const income = 'monthra.income';
  static const expense = 'monthra.expense';
  static const warning = 'monthra.warning';
  static const accentText = 'monthra.accentText';
  static const skeleton = 'monthra.skeleton';
}

/// The light and dark color schemes. Every text role reads at 4.5:1 or more
/// on the background and the cards (test/core/design_system/contrast_test).
abstract final class MonthraColorSchemes {
  static const light = ShadColorScheme(
    background: MonthraPalette.offWhite,
    foreground: MonthraPalette.ink,
    card: MonthraPalette.white,
    cardForeground: MonthraPalette.ink,
    popover: MonthraPalette.white,
    popoverForeground: MonthraPalette.ink,
    primary: MonthraPalette.accent,
    primaryForeground: MonthraPalette.white,
    secondary: MonthraPalette.stone100,
    secondaryForeground: MonthraPalette.ink,
    muted: MonthraPalette.stone100,
    mutedForeground: MonthraPalette.stone600,
    accent: MonthraPalette.stone100,
    accentForeground: MonthraPalette.ink,
    destructive: MonthraPalette.red700,
    destructiveForeground: MonthraPalette.white,
    border: MonthraPalette.stone200,
    input: MonthraPalette.stone300,
    ring: MonthraPalette.accent,
    selection: Color(0x331E6B52),
    custom: {
      _Role.income: MonthraPalette.green700,
      _Role.expense: MonthraPalette.red700,
      _Role.warning: MonthraPalette.amber700,
      _Role.accentText: MonthraPalette.accent,
      _Role.skeleton: MonthraPalette.stone150,
    },
  );

  /// The primary button keeps the brand accent with white text (user
  /// decision of 2026-11-15); text, links and focus use the lifted accent.
  /// Destructive is the soft red with dark text: no red reads at 4.5:1 both
  /// under white text and as text on the graphite background.
  static const dark = ShadColorScheme(
    background: MonthraPalette.graphite,
    foreground: MonthraPalette.offWhite,
    card: MonthraPalette.graphite800,
    cardForeground: MonthraPalette.offWhite,
    popover: MonthraPalette.graphite800,
    popoverForeground: MonthraPalette.offWhite,
    primary: MonthraPalette.accent,
    primaryForeground: MonthraPalette.white,
    secondary: MonthraPalette.graphite700,
    secondaryForeground: MonthraPalette.offWhite,
    muted: MonthraPalette.graphite700,
    mutedForeground: MonthraPalette.stone400,
    accent: MonthraPalette.graphite700,
    accentForeground: MonthraPalette.offWhite,
    destructive: MonthraPalette.red300,
    destructiveForeground: MonthraPalette.graphite,
    border: MonthraPalette.graphite600,
    input: MonthraPalette.graphite500,
    ring: MonthraPalette.accentLight,
    selection: Color(0x553FA37F),
    custom: {
      _Role.income: MonthraPalette.green300,
      _Role.expense: MonthraPalette.red300,
      _Role.warning: MonthraPalette.amber300,
      _Role.accentText: MonthraPalette.accentLight,
      _Role.skeleton: MonthraPalette.graphite700,
    },
  );
}

/// Typed access to the Monthra roles, as in
/// `ShadTheme.of(context).colorScheme.income`.
/// A scheme without them (a test building its own) falls back to the
/// foreground, as `ShadColorScheme.lerp` does.
extension MonthraColors on ShadColorScheme {
  Color get income => custom[_Role.income] ?? foreground;
  Color get expense => custom[_Role.expense] ?? foreground;
  Color get warning => custom[_Role.warning] ?? foreground;

  /// Brand-colored text, links and icons.
  Color get accentText => custom[_Role.accentText] ?? foreground;
  Color get skeleton => custom[_Role.skeleton] ?? muted;
}
