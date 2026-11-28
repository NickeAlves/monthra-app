import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/tokens/breakpoints.dart';
import 'package:monthra/core/design_system/tokens/spacing.dart';

/// How a layout is driven. Buttons are drawn at
/// [MonthraLayout.controlHeight] in both; on phones and tablets a
/// `MonthraTapTarget` gives each the 44 px touch target (§4.4) and fields
/// keep that height, while a desktop layout, driven by a pointer, lets
/// fields drop to the buttons' height (Flutter's desktop target is 24).
enum MonthraDensity {
  touch(MonthraLayout.minTouchTarget, MonthraLayout.minTouchTarget),
  pointer(MonthraLayout.controlHeight, 0);

  new(this.fieldHeight, this.minTapTarget);

  /// Inputs and selects, and the label row of a switch or checkbox.
  final double fieldHeight;

  /// The side of the box a `MonthraTapTarget` grows a control to.
  final double minTapTarget;

  /// Pointer controls from the desktop breakpoint up.
  static MonthraDensity forWidth(double width) =>
      MonthraBreakpoint.forWidth(width) == MonthraBreakpoint.desktop
      ? pointer
      : touch;
}

extension MonthraDensityContext on BuildContext {
  /// The density of the current window width.
  MonthraDensity get monthraDensity =>
      MonthraDensity.forWidth(MediaQuery.sizeOf(this).width);
}
