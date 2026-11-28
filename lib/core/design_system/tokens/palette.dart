import 'dart:ui';

/// The raw colors: the brand pack's (assets/brand/) and the neutrals and
/// semantic tones built around them.
///
/// The look is "Silêncio" (user decision of 2026-11-26): ink, warm greys
/// and space, with the brand green only where it carries meaning (the
/// brand, focus, what is on, money coming in, the charts).
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

  /// The accent lifted for text, links, focus and "on" states on dark
  /// surfaces, where `accent` reads at 2.9:1 only.
  static const accentLight = Color(0xFF3FA37F);

  // Warm near-whites and greys for the light theme.
  /// The page: a hair warmer than white.
  static const paper = Color(0xFFFCFCFB);
  static const stone100 = Color(0xFFF3F3F1);
  static const stone150 = Color(0xFFEFEFEC);
  static const stone200 = Color(0xFFECECE9);
  static const stone300 = Color(0xFFDCDCD8);

  /// A neutral mark in charts: 3:1 on the page and on white.
  static const stone500 = Color(0xFF8F8F8A);
  static const stone600 = Color(0xFF6B6B66);

  // Graphites for the dark theme (never pure black).
  static const graphite850 = Color(0xFF1B1B1B);
  static const graphite800 = Color(0xFF202020);
  static const graphite700 = Color(0xFF262626);
  static const graphite600 = Color(0xFF353535);

  /// A neutral mark in charts: 3:1 on the graphites.
  static const graphite400 = Color(0xFF6A6A66);
  static const stone400 = Color(0xFFA1A19E);

  // Five greens of the accent's hue for the ranked parts of a whole,
  // darkest first on light surfaces and brightest first on dark ones; each
  // reads at 3:1 or more on its theme's surfaces.
  static const greenLight1 = Color(0xFF3E7762);
  static const greenLight2 = Color(0xFF4C856F);
  static const greenLight3 = Color(0xFF58917A);
  static const greenLight4 = Color(0xFF619A83);
  static const greenDark0 = Color(0xFF90D5B9);
  static const greenDark1 = Color(0xFF7ABFA3);
  static const greenDark2 = Color(0xFF65A88E);
  static const greenDark3 = Color(0xFF56977E);
  static const greenDark4 = Color(0xFF47866E);

  // Semantic tones: errors and warnings only (money out reads in ink).
  static const red700 = Color(0xFFA8362A);
  static const red300 = Color(0xFFF28B82);

  /// The hairline of a destructive button: red700's on light surfaces,
  /// red300's on the graphites.
  static const red100 = Color(0xFFEBD5D1);
  static const red900 = Color(0xFF4A2C29);
  static const amber700 = Color(0xFF9A5B00);
  static const amber300 = Color(0xFFF5B44A);
}
