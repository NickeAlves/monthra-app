import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/design_system/design_system.dart';

void main() {
  group('MonthraBreakpoint', () {
    test('splits widths at 640 and 1024 (§4.4)', () {
      expect(MonthraBreakpoint.forWidth(0), MonthraBreakpoint.mobile);
      expect(MonthraBreakpoint.forWidth(639), MonthraBreakpoint.mobile);
      expect(MonthraBreakpoint.forWidth(640), MonthraBreakpoint.tablet);
      expect(MonthraBreakpoint.forWidth(1024), MonthraBreakpoint.tablet);
      expect(MonthraBreakpoint.forWidth(1025), MonthraBreakpoint.desktop);
    });

    testWidgets('reads the window width', (tester) async {
      tester.view
        ..physicalSize = const Size(400, 800)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      late MonthraBreakpoint seen;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            seen = context.monthraBreakpoint;
            return const SizedBox();
          },
        ),
      );
      expect(seen, MonthraBreakpoint.mobile);
    });
  });

  group('MonthraTypography', () {
    final theme = MonthraTypography.textTheme;
    final styles = {
      'h1Large': theme.h1Large,
      'h1': theme.h1,
      'h2': theme.h2,
      'h3': theme.h3,
      'h4': theme.h4,
      'p': theme.p,
      'blockquote': theme.blockquote,
      'table': theme.table,
      'list': theme.list,
      'lead': theme.lead,
      'large': theme.large,
      'small': theme.small,
      'muted': theme.muted,
      'amountDisplay': theme.amountDisplay,
      'amountTitle': theme.amountTitle,
      'amount': theme.amount,
      'amountSmall': theme.amountSmall,
      'label': theme.label,
      'caption': theme.caption,
    };

    test('uses Inter at the bundled weights only', () {
      expect(theme.family, 'Inter');
      for (final MapEntry(:key, :value) in styles.entries) {
        expect(value.fontFamily, 'Inter', reason: key);
        expect(
          MonthraTypography.weights,
          contains(value.fontWeight),
          reason: key,
        );
      }
    });

    test('draws amounts with tabular figures', () {
      for (final style in [
        theme.amountDisplay,
        theme.amountTitle,
        theme.amount,
        theme.amountSmall,
      ]) {
        expect(style.fontFeatures, MonthraTypography.tabularFigures);
      }
    });

    test('tracks titles slightly tighter as they grow', () {
      expect(MonthraTypography.tracking(48), lessThan(0));
      expect(
        MonthraTypography.tracking(48) / 48,
        lessThan(MonthraTypography.tracking(20) / 20),
      );
      expect(MonthraTypography.tracking(12).abs(), lessThan(0.05));
    });

    test('carries no color, like shadcn', () {
      for (final MapEntry(:key, :value) in styles.entries) {
        expect(value.color, isNull, reason: key);
      }
    });
  });

  group('MonthraMotion', () {
    testWidgets('drops durations when the platform asks for less motion', (
      tester,
    ) async {
      final seen = <Duration>[];
      Widget probe() => Builder(
        builder: (context) {
          seen.add(MonthraMotion.of(context, MonthraMotion.normal));
          return const SizedBox();
        },
      );

      await tester.pumpWidget(probe());
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await tester.pumpWidget(
        MediaQuery.fromView(view: tester.view, child: probe()),
      );

      expect(seen.first, const Duration(milliseconds: 200));
      expect(seen.last, Duration.zero);
    });
  });

  group('MonthraDensity', () {
    test('drops to pointer controls on a desktop layout only', () {
      expect(MonthraDensity.forWidth(390), MonthraDensity.touch);
      expect(MonthraDensity.forWidth(1024), MonthraDensity.touch);
      expect(MonthraDensity.forWidth(1025), MonthraDensity.pointer);
      expect(MonthraDensity.touch.controlHeight, MonthraLayout.minTouchTarget);
      expect(MonthraDensity.pointer.controlHeight, 36);
    });
  });

  test('the theme sizes controls by density, with quiet surfaces', () {
    for (final brightness in Brightness.values) {
      for (final density in MonthraDensity.values) {
        final theme = monthraTheme(brightness, density: density);
        expect(theme.buttonSizesTheme.regular!.height, density.controlHeight);
        expect(theme.buttonSizesTheme.icon!.width, density.controlHeight);
        expect(theme.inputTheme.constraints!.minHeight, density.controlHeight);
      }
      final theme = monthraTheme(brightness);
      expect(
        theme.buttonSizesTheme.regular!.height,
        MonthraLayout.minTouchTarget,
      );
      expect(theme.radius, MonthraRadii.smAll);
      expect(theme.cardTheme.radius, MonthraRadii.lgAll);
      expect(theme.cardTheme.shadows, isEmpty);
      expect(theme.textTheme.family, 'Inter');
    }
  });
}
