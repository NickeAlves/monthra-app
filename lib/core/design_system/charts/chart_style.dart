import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/charts/chart_scale.dart';
import 'package:monthra/core/design_system/tokens/spacing.dart';
import 'package:monthra/core/design_system/tokens/typography.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// The look the axis charts share (§4.2: clean charts, no heavy grid, thin
/// lines, quiet tooltips), from the theme's roles.
@immutable
final class ChartStyle {
  const new _(this._theme);

  factory of(ShadThemeData theme) => ChartStyle._(theme);

  final ShadThemeData _theme;

  /// The width kept for the value axis on the left.
  static const double axisWidth = 48;

  /// About the width a short month name (`nov.`) takes, with its gap.
  static const double monthLabelWidth = 36;

  /// The height kept for the labels below.
  static const double bottomHeight = 28;

  static const EdgeInsets tooltipPadding = EdgeInsets.symmetric(
    horizontal: MonthraSpacing.x3,
    vertical: MonthraSpacing.x2,
  );

  static const double tooltipMaxWidth = 200;

  ShadColorScheme get _scheme => _theme.colorScheme;

  /// Behind the selected group or point.
  Color get highlight => _scheme.muted;

  TextStyle get axisLabel => _theme.textTheme.caption.copyWith(
    color: _scheme.mutedForeground,
    fontFeatures: MonthraTypography.tabularFigures,
  );

  TextStyle get tooltipLabel =>
      _theme.textTheme.caption.copyWith(color: _scheme.mutedForeground);

  TextStyle get tooltipValue =>
      _theme.textTheme.amountSmall.copyWith(color: _scheme.popoverForeground);

  /// Thin horizontal lines on the ticks of [scale]; none across.
  FlGridData grid(ChartScale scale) => FlGridData(
    drawVerticalLine: false,
    horizontalInterval: scale.interval,
    getDrawingHorizontalLine: (value) => FlLine(
      color: value == 0 ? _scheme.mutedForeground : _scheme.border,
      strokeWidth: 1,
    ),
  );

  /// The value axis on the left ([formatAxis] on the ticks of [scale]) and
  /// [labels] below, one per index: as many as fit the axis, counted back
  /// from the [highlight]ed one, which always shows and reads stronger.
  FlTitlesData titles({
    required ChartScale scale,
    required String Function(double value) formatAxis,
    required List<String> labels,
    int? highlight,
  }) => FlTitlesData(
    topTitles: const AxisTitles(),
    rightTitles: const AxisTitles(),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: axisWidth,
        interval: scale.interval,
        getTitlesWidget: (value, meta) {
          // fl_chart adds the axis' own ends off the round ticks.
          final steps = (value - scale.min) / scale.interval;
          if ((steps - steps.round()).abs() > 1e-6) {
            return const SizedBox.shrink();
          }
          return SideTitleWidget(
            meta: meta,
            child: Text(formatAxis(value), style: axisLabel, maxLines: 1),
          );
        },
      ),
    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: bottomHeight,
        interval: 1,
        getTitlesWidget: (value, meta) {
          final index = value.round();
          if (value != index || index < 0 || index >= labels.length) {
            return const SizedBox.shrink();
          }
          final shown = visibleLabels(
            count: labels.length,
            width: meta.parentAxisSize,
            labelWidth: monthLabelWidth,
            keep: highlight,
          );
          if (!shown[index]) return const SizedBox.shrink();
          return SideTitleWidget(
            meta: meta,
            child: bottomLabel(labels[index], selected: index == highlight),
          );
        },
      ),
    ),
  );

  /// A label under the axis; the [selected] one in the text color.
  Widget bottomLabel(String text, {bool selected = false}) => Text(
    text,
    style: selected
        ? axisLabel.copyWith(
            color: _scheme.foreground,
            fontWeight: MonthraTypography.semiBold,
          )
        : axisLabel,
    maxLines: 1,
  );

  /// The most the system text size scales the axis labels: their room is
  /// fixed, and the screen shows the same values as text.
  static const double maxTextScale = 1.3;
}
