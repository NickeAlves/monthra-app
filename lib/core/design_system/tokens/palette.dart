import 'dart:ui';

/// The raw colors: the brand pack's (assets/brand/) and the neutrals and
/// semantic tones built around them.
///
/// Widgets never read the palette. They read the roles of the theme's color
/// scheme (`ShadTheme.of(context).colorScheme` plus the `MonthraColors`
/// extension in colors.dart), which pick the right tone for light and dark.
abstract final class MonthraPalette {
  // Brand pack.
  static const accent = Color(0xFF1E6B52);
  static const ink = Color(0xFF161616);
  static const graphite = Color(0xFF141414);
  static const offWhite = Color(0xFFF5F5F3);
  static const white = Color(0xFFFFFFFF);

  /// The accent lifted for text, links and focus on dark surfaces, where
  /// `accent` reads at 2.9:1 only.
  static const accentLight = Color(0xFF3FA37F);

  // Warm neutrals for the light theme, in tune with the off-white.
  static const stone100 = Color(0xFFEDEDEA);
  static const stone150 = Color(0xFFE9E9E6);
  static const stone200 = Color(0xFFE4E4E1);
  static const stone300 = Color(0xFFD4D4D0);
  static const stone400 = Color(0xFFA1A19E);
  static const stone600 = Color(0xFF6B6B68);

  // Graphites for the dark theme (never pure black).
  static const graphite800 = Color(0xFF1C1C1C);
  static const graphite700 = Color(0xFF262626);
  static const graphite600 = Color(0xFF2A2A2A);
  static const graphite500 = Color(0xFF333333);

  // Soft semantic tones: income, expense and warning only.
  static const green700 = Color(0xFF17734C);
  static const green300 = Color(0xFF4CC38A);
  static const red700 = Color(0xFFB42318);
  static const red300 = Color(0xFFF28B82);
  static const amber700 = Color(0xFF9A5B00);
  static const amber300 = Color(0xFFF5B44A);
}
