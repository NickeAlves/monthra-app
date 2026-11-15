import 'package:flutter/widgets.dart';

/// Layout classes by width (§4.4): mobile < 640, tablet 640 to 1024,
/// desktop > 1024.
enum MonthraBreakpoint {
  mobile,
  tablet,
  desktop;

  static const double tabletFrom = 640;
  static const double desktopAbove = 1024;

  static MonthraBreakpoint forWidth(double width) {
    if (width < tabletFrom) return mobile;
    if (width <= desktopAbove) return tablet;
    return desktop;
  }
}

extension MonthraBreakpointContext on BuildContext {
  /// The class of the current window width (shadcn has its own
  /// `breakpoint`, on other widths).
  MonthraBreakpoint get monthraBreakpoint =>
      MonthraBreakpoint.forWidth(MediaQuery.sizeOf(this).width);
}
