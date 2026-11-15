/// The spacing scale, in logical pixels: multiples of 4 (§4.2).
abstract final class MonthraSpacing {
  static const double x1 = 4;
  static const double x2 = 8;
  static const double x3 = 12;
  static const double x4 = 16;
  static const double x5 = 20;
  static const double x6 = 24;
  static const double x8 = 32;
  static const double x10 = 40;
  static const double x12 = 48;
  static const double x16 = 64;
}

/// Layout bounds shared by every screen.
abstract final class MonthraLayout {
  /// Content width on wide screens, beside the sidebar (§4.4).
  static const double maxContentWidth = 1200;

  /// Smallest side of anything that takes a tap (§4.4).
  static const double minTouchTarget = 44;

  /// A field holding a button (show password): the button keeps a whole
  /// touch target inside the field's 1 px border. The other fields of the
  /// same form take this height too, so they line up.
  static const double fieldWithButtonHeight = minTouchTarget + 2;

  /// Widest a centered message (empty and error states) gets.
  static const double maxMessageWidth = 360;
}
