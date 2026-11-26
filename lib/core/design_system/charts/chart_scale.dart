import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// A value axis with round ticks: from [min] to [max] in steps of
/// [interval] (1, 2, 2.5 or 5 times a power of ten).
@immutable
final class ChartScale {
  const new({required this.min, required this.max, required this.interval});

  /// The smallest round axis holding every one of [values] in about
  /// [ticks] steps. With [includeZero] the axis starts at (or goes through)
  /// zero, as bars need; a line keeps only the range of its values. An empty
  /// or flat range still gets an axis.
  factory fit(
    Iterable<double> values, {
    int ticks = 4,
    bool includeZero = true,
  }) {
    var low = values.fold(double.infinity, math.min);
    var high = values.fold(double.negativeInfinity, math.max);
    if (low.isInfinite || high.isInfinite) low = high = 0;
    if (includeZero) {
      low = math.min(low, 0);
      high = math.max(high, 0);
    }
    if (high == low) {
      final pad = high == 0 ? 1.0 : high.abs() * 0.1;
      high += pad;
      if (!includeZero || low < 0) low -= pad;
    }
    final interval = niceStep((high - low) / ticks);
    final min = (low / interval).floorToDouble() * interval;
    final max = (high / interval).ceilToDouble() * interval;
    return ChartScale(min: min, max: max, interval: interval);
  }

  final double min;
  final double max;
  final double interval;

  /// The ticks from [min] to [max].
  List<double> get ticks => [
    for (var v = min; v <= max + interval / 2; v += interval) v,
  ];

  /// The round step (1, 2, 2.5 or 5 times a power of ten) at or above
  /// [raw].
  static double niceStep(double raw) {
    if (raw <= 0 || raw.isNaN) return 1;
    final magnitude = math
        .pow(10, (math.log(raw) / math.ln10).floor())
        .toDouble();
    for (final factor in const [1.0, 2.0, 2.5, 5.0, 10.0]) {
      if (factor * magnitude >= raw - 1e-9) return factor * magnitude;
    }
    return 10 * magnitude;
  }
}

/// Which of [count] labels along an axis show: one every few, counted back
/// from [keep] (the selected one, which always shows; the last by
/// default), so that labels about [labelWidth] wide fit in [width].
List<bool> visibleLabels({
  required int count,
  required double width,
  required double labelWidth,
  int? keep,
}) {
  if (count == 0) return const [];
  final fit = math.max(1, (width / labelWidth).floor());
  final step = math.max(1, (count / fit).ceil());
  final anchor = keep ?? count - 1;
  return [for (var i = 0; i < count; i++) (anchor - i) % step == 0];
}
