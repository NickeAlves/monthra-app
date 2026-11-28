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
  static const brand = 'monthra.brand';
  static const onBrand = 'monthra.onBrand';
  static const chartMuted = 'monthra.chartMuted';
  static const destructiveBorder = 'monthra.destructiveBorder';
  static const ramp = [
    'monthra.ramp0',
    'monthra.ramp1',
    'monthra.ramp2',
    'monthra.ramp3',
    'monthra.ramp4',
  ];
}

/// The light and dark color schemes. Every text role reads at 4.5:1 or more
/// on the background, the cards, the popovers and muted (test/core/
/// design_system/contrast_test).
///
/// "Silêncio" (user decision of 2026-11-26): the primary button is ink (the
/// light text color on dark), money out reads in ink with its minus, and
/// green marks the brand, focus, "on" states, money in and the charts. Red
/// is for errors: a destructive button is its red label in a hairline.
/// Sections sit on the page itself; cards and popovers are the one lifted
/// surface.
abstract final class MonthraColorSchemes {
  static const light = ShadColorScheme(
    background: MonthraPalette.paper,
    foreground: MonthraPalette.ink,
    card: MonthraPalette.white,
    cardForeground: MonthraPalette.ink,
    popover: MonthraPalette.white,
    popoverForeground: MonthraPalette.ink,
    primary: MonthraPalette.ink,
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
      _Role.income: MonthraPalette.accent,
      _Role.expense: MonthraPalette.ink,
      _Role.warning: MonthraPalette.amber700,
      _Role.accentText: MonthraPalette.accent,
      _Role.skeleton: MonthraPalette.stone150,
      _Role.brand: MonthraPalette.accent,
      _Role.onBrand: MonthraPalette.white,
      _Role.chartMuted: MonthraPalette.stone500,
      _Role.destructiveBorder: MonthraPalette.red100,
      'monthra.ramp0': MonthraPalette.accent,
      'monthra.ramp1': MonthraPalette.greenLight1,
      'monthra.ramp2': MonthraPalette.greenLight2,
      'monthra.ramp3': MonthraPalette.greenLight3,
      'monthra.ramp4': MonthraPalette.greenLight4,
    },
  );

  /// Ink turns to the off-white: the primary button is off-white with
  /// graphite text. Destructive is the soft red with dark text: no red
  /// reads at 4.5:1 both under white text and as text on the graphite.
  static const dark = ShadColorScheme(
    background: MonthraPalette.graphite,
    foreground: MonthraPalette.offWhite,
    card: MonthraPalette.graphite850,
    cardForeground: MonthraPalette.offWhite,
    popover: MonthraPalette.graphite850,
    popoverForeground: MonthraPalette.offWhite,
    primary: MonthraPalette.offWhite,
    primaryForeground: MonthraPalette.graphite,
    secondary: MonthraPalette.graphite800,
    secondaryForeground: MonthraPalette.offWhite,
    muted: MonthraPalette.graphite800,
    mutedForeground: MonthraPalette.stone400,
    accent: MonthraPalette.graphite800,
    accentForeground: MonthraPalette.offWhite,
    destructive: MonthraPalette.red300,
    destructiveForeground: MonthraPalette.graphite,
    border: MonthraPalette.graphite700,
    input: MonthraPalette.graphite600,
    ring: MonthraPalette.accentLight,
    selection: Color(0x553FA37F),
    custom: {
      _Role.income: MonthraPalette.accentLight,
      _Role.expense: MonthraPalette.offWhite,
      _Role.warning: MonthraPalette.amber300,
      _Role.accentText: MonthraPalette.accentLight,
      _Role.skeleton: MonthraPalette.graphite800,
      _Role.brand: MonthraPalette.accent,
      _Role.onBrand: MonthraPalette.white,
      _Role.chartMuted: MonthraPalette.graphite400,
      _Role.destructiveBorder: MonthraPalette.red900,
      'monthra.ramp0': MonthraPalette.greenDark0,
      'monthra.ramp1': MonthraPalette.greenDark1,
      'monthra.ramp2': MonthraPalette.greenDark2,
      'monthra.ramp3': MonthraPalette.greenDark3,
      'monthra.ramp4': MonthraPalette.greenDark4,
    },
  );
}

/// Typed access to the Monthra roles, as in
/// `ShadTheme.of(context).colorScheme.income`.
/// A scheme without them (a test building its own) falls back to the
/// foreground, as `ShadColorScheme.lerp` does.
extension MonthraColors on ShadColorScheme {
  /// Money in: the green.
  Color get income => custom[_Role.income] ?? foreground;

  /// Money out: the text color (its minus says what it is).
  Color get expense => custom[_Role.expense] ?? foreground;
  Color get warning => custom[_Role.warning] ?? foreground;

  /// Brand-colored text, links, icons and "on" states (a checked box, a
  /// switch).
  Color get accentText => custom[_Role.accentText] ?? foreground;
  Color get skeleton => custom[_Role.skeleton] ?? muted;

  /// The brand green as a fill in both themes (the sign-in panel), with
  /// [onBrand] over it.
  Color get brand => custom[_Role.brand] ?? primary;
  Color get onBrand => custom[_Role.onBrand] ?? primaryForeground;

  /// A neutral mark in charts (money out beside money in, "others").
  Color get chartMuted => custom[_Role.chartMuted] ?? mutedForeground;

  /// The border of a destructive button, whose label is [destructive] on
  /// the surface it sits on.
  Color get destructiveBorder => custom[_Role.destructiveBorder] ?? border;

  /// Greens for the ranked parts of a whole (a donut's slices), the
  /// strongest first; each reads at 3:1 on the surfaces.
  List<Color> get chartRamp => [
    for (final key in _Role.ramp) custom[key] ?? accentText,
  ];
}
