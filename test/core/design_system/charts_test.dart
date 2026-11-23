import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/design_system/design_system.dart';

import '../../helpers/frame.dart';

void main() {
  group('ChartScale', () {
    test('rounds the step to 1, 2, 2.5 or 5 times a power of ten', () {
      expect(ChartScale.niceStep(0.7), 1);
      expect(ChartScale.niceStep(1.3), 2);
      expect(ChartScale.niceStep(2.2), 2.5);
      expect(ChartScale.niceStep(3.1), 5);
      expect(ChartScale.niceStep(7), 10);
      expect(ChartScale.niceStep(212500), 250000);
      expect(ChartScale.niceStep(0), 1);
    });

    test('bars start at zero and end on a round tick', () {
      final scale = ChartScale.fit([850000, 412345, 300000]);
      expect(scale.min, 0);
      expect(scale.interval, 250000);
      expect(scale.max, 1000000);
      expect(scale.ticks, [0, 250000, 500000, 750000, 1000000]);
    });

    test('a line keeps the range of its values', () {
      final scale = ChartScale.fit([1500000, 1938321], includeZero: false);
      // A range of 438.321 in four steps: 200.000 each, on round ticks.
      expect(scale.interval, 200000);
      expect(scale.min, 1400000);
      expect(scale.max, 2000000);
    });

    test('negative values hang below zero', () {
      final scale = ChartScale.fit([-120, 300]);
      expect(scale.min, lessThanOrEqualTo(-120));
      expect(scale.max, greaterThanOrEqualTo(300));
      expect(scale.min % scale.interval, 0);
    });

    test('no value or one flat value still gets an axis', () {
      final empty = ChartScale.fit(const []);
      expect(empty.max, greaterThan(empty.min));
      final flat = ChartScale.fit([118000, 118000], includeZero: false);
      expect(flat.min, lessThan(118000));
      expect(flat.max, greaterThan(118000));
    });
  });

  group('visibleLabels', () {
    test('shows every label that fits', () {
      expect(
        visibleLabels(count: 12, width: 600, labelWidth: 36),
        List.filled(12, true),
      );
    });

    test('skips labels counted back from the selected one', () {
      final shown = visibleLabels(
        count: 12,
        width: 300,
        labelWidth: 36,
        keep: 10,
      );
      expect(
        [
          for (final (i, s) in shown.indexed)
            if (s) i,
        ],
        [0, 2, 4, 6, 8, 10],
      );
    });

    test('the last one shows by default', () {
      final shown = visibleLabels(count: 12, width: 150, labelWidth: 36);
      expect(shown.last, isTrue);
      expect(shown.where((s) => s), hasLength(4));
    });
  });

  testWidgets('a chart reads as its label, not its canvas', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpFrame(
      const Column(
        children: [
          MonthraDonutChart(semanticLabel: 'Gastos por categoria', slices: []),
          SizedBox(
            width: 400,
            child: MonthraBarChart(
              semanticLabel: 'Entradas e saídas',
              labels: ['out.', 'nov.'],
              series: [],
              formatAxis: _axis,
              formatValue: _axis,
            ),
          ),
        ],
      ),
    );
    expect(find.bySemanticsLabel('Gastos por categoria'), findsOneWidget);
    expect(find.bySemanticsLabel('Entradas e saídas'), findsOneWidget);
    expect(find.bySemanticsLabel('nov.'), findsNothing);
    semantics.dispose();
  });

  testWidgets('axis charts sit in an equal-height row', (tester) async {
    const labels = ['out.', 'nov.'];
    await _inIntrinsicRow(
      tester,
      const MonthraBarChart(
        semanticLabel: 'Barras',
        labels: labels,
        series: [
          BarSeries(name: 'A', color: Color(0xFF22C55E), values: [1, 2]),
        ],
        formatAxis: _axis,
        formatValue: _axis,
      ),
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(MonthraBarChart)).height, 220);

    await _inIntrinsicRow(
      tester,
      const MonthraLineChart(
        semanticLabel: 'Linha',
        labels: labels,
        values: [1, null],
        color: Color(0xFF1E6B52),
        formatAxis: _axis,
        formatValue: _axis,
      ),
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(MonthraLineChart)).height, 200);
  });

  testWidgets('charts hold still under reduced motion', (tester) async {
    tester.reduceMotion();
    await tester.pumpFrame(
      const MonthraDonutChart(
        semanticLabel: 'Gastos',
        slices: [DonutSlice(value: 1, color: Color(0xFF22C55E))],
      ),
    );
    final chart = tester.widget<PieChart>(find.byType(PieChart));
    expect(chart.duration, Duration.zero);
  });
}

String _axis(double value) => value.toStringAsFixed(0);

/// Fixed-height charts can share an equal-height row (no LayoutBuilder).
Future<void> _inIntrinsicRow(WidgetTester tester, Widget chart) =>
    tester.pumpFrame(
      IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: chart),
            const SizedBox(width: 40),
          ],
        ),
      ),
    );
