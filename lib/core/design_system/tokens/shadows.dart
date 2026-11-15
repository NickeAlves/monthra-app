import 'package:flutter/widgets.dart';

/// Shadows that are barely there (§4.2). The dark theme draws none: its
/// cards stand out by their border and a lighter surface.
abstract final class MonthraShadows {
  static const List<BoxShadow> subtle = [
    BoxShadow(color: Color(0x0A161616), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x08161616), blurRadius: 8, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> none = [];

  static List<BoxShadow> card(Brightness brightness) =>
      brightness == Brightness.light ? subtle : none;
}
