import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/charts/chart_scale.dart';
import 'package:monthra/core/design_system/charts/chart_style.dart';
import 'package:monthra/core/design_system/color_utils.dart';
import 'package:monthra/core/design_system/tokens/motion.dart';
import 'package:monthra/core/design_system/tokens/radii.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// One series of a [MonthraBarChart]: a bar in every group.
@immutable
final class BarSeries {
  const new({required this.name, required this.color, required this.values});

  /// Read in the tooltip (`Income`).
  final String name;
  final Color color;

  /// One per group; negative values hang below zero.
  final List<double> values;
}

/// Groups of side-by-side bars over [labels] (months, say), on a value
/// axis with round ticks and thin horizontal lines only. The [highlight]ed
/// group sits on a soft column and its label reads stronger. Hovering or
/// touching a bar shows its series and value ([formatValue]); the axis
/// writes [formatAxis].
///
/// Its height is fixed, so it can sit in an `IntrinsicHeight` row. The bars
/// are a picture: assistive technologies read [semanticLabel].
class MonthraBarChart extends StatelessWidget {
  const new({
    required this.labels,
    required this.series,
    required this.semanticLabel,
    required this.formatAxis,
    required this.formatValue,
    this.highlight,
    this.height = 220,
    this.barWidth = 10,
    super.key,
  });

  final List<String> labels;
  final List<BarSeries> series;
  final String semanticLabel;
  final String Function(double value) formatAxis;
  final String Function(double value) formatValue;
  final int? highlight;
  final double height;

  /// Each bar's width; a group holds one per series, side by side.
  final double barWidth;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final scheme = theme.colorScheme;
    final style = ChartStyle.of(theme);
    final scale = ChartScale.fit([for (final s in series) ...s.values]);
    final colors = [
      for (final s in series) ensureContrast(s.color, scheme.card),
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
            child: BarChart(
              BarChartData(
                minY: scale.min,
                maxY: scale.max,
                alignment: BarChartAlignment.spaceAround,
                gridData: style.grid(scale),
                borderData: FlBorderData(show: false),
                titlesData: style.titles(
                  scale: scale,
                  formatAxis: formatAxis,
                  labels: labels,
                  highlight: highlight,
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => scheme.popover,
                    tooltipBorder: BorderSide(color: scheme.border),
                    tooltipBorderRadius: MonthraRadii.smAll,
                    tooltipPadding: ChartStyle.tooltipPadding,
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    maxContentWidth: ChartStyle.tooltipMaxWidth,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                        BarTooltipItem(
                          '${labels[groupIndex]}\n',
                          style.tooltipLabel,
                          children: [
                            TextSpan(
                              text:
                                  '${series[rodIndex].name} '
                                  '${formatValue(rod.toY)}',
                              style: style.tooltipValue,
                            ),
                          ],
                        ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < labels.length; i++)
                    BarChartGroupData(
                      x: i,
                      barsSpace: barWidth / 3,
                      barRods: [
                        for (final (s, line) in series.indexed)
                          BarChartRodData(
                            toY: i < line.values.length ? line.values[i] : 0,
                            color: colors[s],
                            width: barWidth,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(barWidth / 3),
                            ),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: i == highlight,
                              fromY: scale.min,
                              toY: scale.max,
                              color: style.highlight,
                            ),
                          ),
                      ],
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
