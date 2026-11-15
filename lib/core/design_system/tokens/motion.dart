import 'package:flutter/widgets.dart';

/// Motion: transitions of 150 to 250 ms on `easeOutCubic` (§4.2).
abstract final class MonthraMotion {
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 200);
  static const slow = Duration(milliseconds: 250);

  /// A total counting to its new value.
  static const number = Duration(milliseconds: 400);

  /// One skeleton pulse.
  static const pulse = Duration(milliseconds: 1600);

  static const Curve curve = Curves.easeOutCubic;

  /// [duration], or zero when the platform asks for less motion.
  static Duration of(BuildContext context, Duration duration) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
}
