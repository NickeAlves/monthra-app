import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/tokens/breakpoints.dart';
import 'package:monthra/core/design_system/tokens/spacing.dart';

/// How tall controls are drawn: a whole touch target on phones and tablets,
/// lighter on a desktop layout, where a pointer drives them (§4.4 keeps
/// 44 px for touch; Flutter's desktop guideline asks 24).
enum MonthraDensity {
  touch(MonthraLayout.minTouchTarget),
  pointer(MonthraLayout.pointerControlHeight);

  new(this.controlHeight);

  /// Buttons, icon buttons, inputs and selects.
  final double controlHeight;

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
