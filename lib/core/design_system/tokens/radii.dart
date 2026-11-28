import 'package:flutter/widgets.dart';

/// Corner radii, small and quiet ("Silêncio"): 7 for controls, 9 for icon
/// tiles and highlighted rows, 12 for the lifted surfaces (cards, dialogs,
/// sheets, popovers), and 4 for controls of 16 px (a checkbox), which 7
/// would turn into circles.
abstract final class MonthraRadii {
  static const double xs = 4;
  static const double sm = 7;
  static const double md = 9;
  static const double lg = 12;

  /// Fully rounded ends (badges, pills).
  static const double pill = 999;

  static const xsAll = BorderRadius.all(Radius.circular(xs));
  static const smAll = BorderRadius.all(Radius.circular(sm));
  static const mdAll = BorderRadius.all(Radius.circular(md));
  static const lgAll = BorderRadius.all(Radius.circular(lg));
  static const pillAll = BorderRadius.all(Radius.circular(pill));
}
