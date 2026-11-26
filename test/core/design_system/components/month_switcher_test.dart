import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/dates/year_month.dart';
import 'package:monthra/core/design_system/design_system.dart';

import '../../../helpers/frame.dart';

const labels = (
  previous: 'Mês anterior',
  next: 'Próximo mês',
  current: 'Este mês',
);
const current = YearMonth(2026, 11);

void main() {
  /// The switcher showing [month], pinned to the end of a row (as a
  /// header's actions sit) or to its start; answers where the "previous"
  /// arrow is.
  Future<Offset> arrowAt(
    WidgetTester tester, {
    required YearMonth month,
    required MonthSwitcherAnchor anchor,
    Size size = const Size(1280, 200),
  }) async {
    await tester.pumpFrame(
      SizedBox(
        width: size.width - 32,
        child: Row(
          children: [
            if (anchor == MonthSwitcherAnchor.end) const Spacer(),
            MonthSwitcher(
              month: month,
              current: current,
              onChanged: (_) {},
              labels: labels,
              anchor: anchor,
            ),
            if (anchor == MonthSwitcherAnchor.start) const Spacer(),
          ],
        ),
      ),
      size: size,
    );
    return tester.getTopLeft(find.bySemanticsLabel(labels.previous));
  }

  for (final anchor in MonthSwitcherAnchor.values) {
    testWidgets('the arrows stay put pinned to the ${anchor.name}', (
      tester,
    ) async {
      final atCurrent = await arrowAt(tester, month: current, anchor: anchor);
      expect(find.text(labels.current), findsNothing);
      final away = await arrowAt(
        tester,
        month: current.addMonths(-3),
        anchor: anchor,
      );
      expect(find.text(labels.current), findsOneWidget);
      expect(away, atCurrent);

      // The way back sits on the free side.
      final back = tester.getCenter(find.text(labels.current)).dx;
      if (anchor == MonthSwitcherAnchor.end) {
        expect(back, lessThan(away.dx));
      } else {
        expect(back, greaterThan(away.dx));
      }
    });
  }

  testWidgets('follows the breakpoint by default', (tester) async {
    late MonthSwitcherAnchor phone;
    late MonthSwitcherAnchor desktop;
    await tester.pumpFrame(
      Builder(
        builder: (context) {
          phone = MonthSwitcher.defaultAnchor(context);
          return const SizedBox();
        },
      ),
      size: const Size(390, 844),
    );
    await tester.pumpFrame(
      Builder(
        builder: (context) {
          desktop = MonthSwitcher.defaultAnchor(context);
          return const SizedBox();
        },
      ),
      size: const Size(1280, 800),
    );
    expect(phone, MonthSwitcherAnchor.start);
    expect(desktop, MonthSwitcherAnchor.end);
  });

  testWidgets('moves a month each way and back to the current', (tester) async {
    final picked = <YearMonth>[];
    await tester.pumpFrame(
      MonthSwitcher(
        month: const YearMonth(2026, 9),
        current: current,
        onChanged: picked.add,
        labels: labels,
      ),
      size: const Size(1280, 200),
    );
    expect(find.text('Setembro de 2026'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel(labels.previous));
    await tester.tap(find.bySemanticsLabel(labels.next));
    await tester.tap(find.text(labels.current));
    expect(picked, [
      const YearMonth(2026, 8),
      const YearMonth(2026, 10),
      current,
    ]);
  });
}
