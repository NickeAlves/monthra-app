import 'package:flutter/widgets.dart';

/// Corner radii: soft, from 8 to 12 (§4.2), and 4 for controls of 16 px
/// (a checkbox), which 8 would turn into circles.
abstract final class MonthraRadii {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 10;
  static const double lg = 12;

  /// Fully rounded ends (badges, pills).
  static const double pill = 999;

  static const xsAll = BorderRadius.all(Radius.circular(xs));
  static const smAll = BorderRadius.all(Radius.circular(sm));
  static const mdAll = BorderRadius.all(Radius.circular(md));
  static const lgAll = BorderRadius.all(Radius.circular(lg));
  static const pillAll = BorderRadius.all(Radius.circular(pill));
}
