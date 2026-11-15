import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/design_system/design_system.dart';

import '../../../helpers/frame.dart';

double alphaOf(WidgetTester tester, Finder skeleton) {
  final box = tester.widget<DecoratedBox>(
    find.descendant(of: skeleton, matching: find.byType(DecoratedBox)),
  );
  return (box.decoration as BoxDecoration).color!.a;
}

void main() {
  test('pulses from 1 down to 0.4 once per period', () {
    expect(skeletonOpacity(Duration.zero), closeTo(1, 1e-9));
    expect(skeletonOpacity(MonthraMotion.pulse ~/ 2), closeTo(0.4, 1e-9));
    expect(skeletonOpacity(MonthraMotion.pulse ~/ 4), closeTo(0.7, 1e-9));
    expect(skeletonOpacity(MonthraMotion.pulse), closeTo(1, 1e-9));
  });

  testWidgets('pulses, every skeleton in step', (tester) async {
    await tester.pumpFrame(
      const Column(
        children: [
          Skeleton(width: 100, key: Key('a')),
          Skeleton.circle(size: 20, key: Key('b')),
        ],
      ),
    );
    final a = find.byKey(const Key('a'));
    final b = find.byKey(const Key('b'));
    await tester.pump(const Duration(milliseconds: 100));
    final first = alphaOf(tester, a);
    await tester.pump(const Duration(milliseconds: 500));
    expect(alphaOf(tester, a), isNot(first));
    expect(alphaOf(tester, a), alphaOf(tester, b));
  });

  testWidgets('holds still when the platform asks for less motion', (
    tester,
  ) async {
    tester.reduceMotion();
    await tester.pumpFrame(const Skeleton(width: 100));
    final skeleton = find.byType(Skeleton);
    final still = alphaOf(tester, skeleton);
    await tester.pump(const Duration(milliseconds: 500));
    expect(alphaOf(tester, skeleton), still);
    // A running pulse would never settle.
    await tester.pumpAndSettle();
  });

  testWidgets('is hidden from assistive technologies', (tester) async {
    await tester.pumpFrame(const Skeleton(width: 100));
    expect(
      find.descendant(
        of: find.byType(Skeleton),
        matching: find.byType(ExcludeSemantics),
      ),
      findsOneWidget,
    );
  });

  testWidgets('a circle is round and square', (tester) async {
    await tester.pumpFrame(const Skeleton.circle(size: 36));
    expect(tester.getSize(find.byType(Skeleton)), const Size.square(36));
    expect(
      tester.widget<Skeleton>(find.byType(Skeleton)).radius,
      MonthraRadii.pillAll,
    );
  });

  testWidgets('text lines end with a shorter one', (tester) async {
    tester.reduceMotion();
    await tester.pumpFrame(const SizedBox(width: 200, child: SkeletonText()));
    final lines = find.byType(Skeleton);
    expect(lines, findsNWidgets(3));
    expect(tester.getSize(lines.at(0)).width, 200);
    expect(tester.getSize(lines.at(2)).width, 120);
  });
}
