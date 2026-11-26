import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/color_utils.dart';
import 'package:monthra/core/design_system/tokens/motion.dart';
import 'package:monthra/core/design_system/tokens/spacing.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// A part of a [MonthraDonutChart].
@immutable
final class DonutSlice {
  const new({required this.value, required this.color});

  /// Any positive size; the slices share the ring by it.
  final double value;
  final Color color;
}

/// Parts of a whole on a thin ring (fl_chart), with [center] inside it (a
/// total, say). Slice colors are moved until they read at 3:1 on the card
/// (WCAG 1.4.11), with a gap between slices. With no positive slice the ring
/// is drawn empty, in the border color.
///
/// The ring is a picture: assistive technologies read [semanticLabel]
/// instead (a sentence that says what it shows; the screen lists the parts
/// as text too).
class MonthraDonutChart extends StatelessWidget {
  const new({
    required this.slices,
    required this.semanticLabel,
    this.center,
    this.size = 168,
    this.thickness = 16,
    super.key,
  });

  final List<DonutSlice> slices;
  final String semanticLabel;
  final Widget? center;
  final double size;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    final scheme = ShadTheme.of(context).colorScheme;
    final parts = [
      for (final s in slices)
        if (s.value > 0) s,
    ];
    final sections = parts.isEmpty
        ? [
            PieChartSectionData(
              value: 1,
              color: scheme.border,
              radius: thickness,
              showTitle: false,
            ),
          ]
        : [
            for (final s in parts)
              PieChartSectionData(
                value: s.value,
                color: ensureContrast(s.color, scheme.card),
                radius: thickness,
                showTitle: false,
              ),
          ];
    return Semantics(
      container: true,
      image: true,
      label: semanticLabel,
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: size / 2 - thickness,
                  sectionsSpace: parts.length > 1 ? 2 : 0,
                  // The top, clockwise: the largest part starts at noon.
                  startDegreeOffset: -90,
                  pieTouchData: PieTouchData(enabled: false),
                  borderData: FlBorderData(show: false),
                ),
                duration: MonthraMotion.of(context, MonthraMotion.slow),
                curve: MonthraMotion.curve,
              ),
              if (center case final center?)
                Padding(
                  padding: EdgeInsets.all(thickness + MonthraSpacing.x2),
                  child: center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
