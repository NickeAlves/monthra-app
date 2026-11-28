import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/charts/chart_scale.dart';
import 'package:monthra/core/design_system/charts/chart_style.dart';
import 'package:monthra/core/design_system/color_utils.dart';
import 'package:monthra/core/design_system/tokens/motion.dart';
import 'package:monthra/core/design_system/tokens/radii.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// One value per label (months, say) on a thin line (no fill),
/// with round ticks and thin horizontal lines only. A null value leaves its
/// label without a point (a month still to come), and the line stops there.
/// The [highlight]ed point gets a dot and a stronger label. Hovering or
/// touching shows the value ([formatValue]); the axis writes [formatAxis].
///
/// Its height is fixed, so it can sit in an `IntrinsicHeight` row. The
/// line is a picture: assistive technologies read [semanticLabel].
class MonthraLineChart extends StatelessWidget {
  const new({
    required this.labels,
    required this.values,
    required this.color,
    required this.semanticLabel,
    required this.formatAxis,
    required this.formatValue,
    this.highlight,
    this.height = 200,
    super.key,
  });

  final List<String> labels;
  final List<double?> values;
  final Color color;
  final String semanticLabel;
  final String Function(double value) formatAxis;
  final String Function(double value) formatValue;
  final int? highlight;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final scheme = theme.colorScheme;
    final style = ChartStyle.of(theme);
    // Charts sit on the page, in sections.
    final line = ensureContrast(color, scheme.background);
    final known = [for (final v in values) ?v];
    final scale = ChartScale.fit(known, includeZero: false);
    final spots = [
      for (var i = 0; i < labels.length; i++)
        if (i < values.length && values[i] != null)
          FlSpot(i.toDouble(), values[i]!)
        else
          FlSpot.nullSpot,
    ];
    return Semantics(
      container: true,
      image: true,
      label: semanticLabel,
      child: ExcludeSemantics(
        child: MediaQuery.withClampedTextScaling(
          maxScaleFactor: ChartStyle.maxTextScale,
          child: SizedBox(
            height: height,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: labels.isEmpty ? 1 : labels.length - 1.0,
                minY: scale.min,
                maxY: scale.max,
                gridData: style.grid(scale),
                borderData: FlBorderData(show: false),
                titlesData: style.titles(
                  scale: scale,
                  formatAxis: formatAxis,
                  labels: labels,
                  highlight: highlight,
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => scheme.popover,
                    tooltipBorder: BorderSide(color: scheme.border),
                    tooltipBorderRadius: MonthraRadii.smAll,
                    tooltipPadding: ChartStyle.tooltipPadding,
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    maxContentWidth: ChartStyle.tooltipMaxWidth,
                    getTooltipItems: (spots) => [
                      for (final spot in spots)
                        LineTooltipItem(
                          '${labels[spot.x.round()]}\n',
                          style.tooltipLabel,
                          children: [
                            TextSpan(
                              text: formatValue(spot.y),
                              style: style.tooltipValue,
                            ),
                          ],
                        ),
                    ],
                  ),
                  getTouchedSpotIndicator: (bar, indexes) => [
                    for (final _ in indexes)
                      TouchedSpotIndicatorData(
                        FlLine(color: scheme.border, strokeWidth: 1),
                        FlDotData(
                          getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                            radius: 4,
                            color: line,
                            strokeWidth: 2,
                            strokeColor: scheme.background,
                          ),
                        ),
                      ),
                  ],
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    color: line,
                    barWidth: 1.75,
                    isCurved: true,
                    preventCurveOverShooting: true,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      checkToShowDot: (spot, _) =>
                          highlight != null && spot.x == highlight,
                      getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                        radius: 4,
                        color: line,
                        strokeWidth: 2,
                        strokeColor: scheme.background,
                      ),
                    ),
                  ),
                ],
              ),
              duration: MonthraMotion.of(context, MonthraMotion.slow),
              curve: MonthraMotion.curve,
            ),
          ),
        ),
      ),
    );
  }
}
