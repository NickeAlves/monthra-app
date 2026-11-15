import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Keys of the Monthra styles kept in [ShadTextTheme.custom].
abstract final class _Style {
  static const amountDisplay = 'monthra.amountDisplay';
  static const amountTitle = 'monthra.amountTitle';
  static const amount = 'monthra.amount';
  static const amountSmall = 'monthra.amountSmall';
  static const label = 'monthra.label';
  static const caption = 'monthra.caption';
}

/// Inter at 400, 500 and 600 only (§4.2), bundled in assets/fonts/inter.
///
/// Styles carry no color, like shadcn's: components apply the role they
/// need, and plain text takes the foreground from the app.
abstract final class MonthraTypography {
  static const family = 'Inter';

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;

  /// The only weights the bundled cuts cover.
  static const List<FontWeight> weights = [regular, medium, semiBold];

  /// Same-width digits, so amounts line up and do not jitter while counting.
  static const List<FontFeature> tabularFigures = [
    FontFeature.tabularFigures(),
  ];

  /// Inter's dynamic metrics (rsms.me/inter/dynmetrics): tracking in em is
  /// -0.0223 + 0.185 * e^(-0.1745 * size), slightly negative on titles.
  static double tracking(double fontSize) =>
      fontSize * (-0.0223 + 0.185 * math.exp(-0.1745 * fontSize));

  static TextStyle style(
    double fontSize,
    FontWeight weight, {
    required double lineHeight,
    List<FontFeature>? fontFeatures,
  }) => TextStyle(
    fontFamily: family,
    fontSize: fontSize,
    fontWeight: weight,
    height: lineHeight / fontSize,
    letterSpacing: tracking(fontSize),
    fontFeatures: fontFeatures,
    textBaseline: TextBaseline.alphabetic,
    leadingDistribution: TextLeadingDistribution.even,
    decoration: TextDecoration.none,
  );

  static TextStyle _amount(
    double fontSize,
    FontWeight weight, {
    required double lineHeight,
  }) => style(
    fontSize,
    weight,
    lineHeight: lineHeight,
    fontFeatures: tabularFigures,
  );

  /// The text theme of both brightnesses.
  static final ShadTextTheme textTheme = ShadTextTheme(
    family: family,
    h1Large: style(48, semiBold, lineHeight: 52),
    h1: style(36, semiBold, lineHeight: 40),
    h2: style(30, semiBold, lineHeight: 36),
    h3: style(24, semiBold, lineHeight: 32),
    h4: style(20, semiBold, lineHeight: 28),
    p: style(16, regular, lineHeight: 26),
    blockquote: style(
      16,
      regular,
      lineHeight: 24,
    ).copyWith(fontStyle: FontStyle.italic),
    table: style(16, semiBold, lineHeight: 24),
    list: style(16, regular, lineHeight: 24),
    lead: style(18, regular, lineHeight: 28),
    large: style(18, medium, lineHeight: 28),
    small: style(14, medium, lineHeight: 20),
    muted: style(14, regular, lineHeight: 20),
    custom: {
      _Style.amountDisplay: _amount(40, semiBold, lineHeight: 48),
      _Style.amountTitle: _amount(24, semiBold, lineHeight: 32),
      _Style.amount: _amount(16, medium, lineHeight: 24),
      _Style.amountSmall: _amount(14, medium, lineHeight: 20),
      _Style.label: style(14, medium, lineHeight: 20),
      _Style.caption: style(12, regular, lineHeight: 16),
    },
  );
}

/// Typed access to the Monthra styles, as in
/// `ShadTheme.of(context).textTheme.amount`.
/// A theme without them falls back to the closest shadcn style.
extension MonthraTextStyles on ShadTextTheme {
  /// The headline total of a screen (balance, net worth).
  TextStyle get amountDisplay => custom[_Style.amountDisplay] ?? h1;

  /// The total of a card.
  TextStyle get amountTitle => custom[_Style.amountTitle] ?? h3;

  /// An amount in a list or a form.
  TextStyle get amount => custom[_Style.amount] ?? p;
  TextStyle get amountSmall => custom[_Style.amountSmall] ?? small;

  /// Field labels, tile titles.
  TextStyle get label => custom[_Style.label] ?? small;

  /// Helper text, timestamps.
  TextStyle get caption => custom[_Style.caption] ?? muted;
}
