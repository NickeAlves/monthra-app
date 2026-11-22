import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/app/router.dart';
import 'package:monthra/core/design_system/catalog/design_system_catalog.dart';
import 'package:monthra/core/design_system/catalog/sample_categories.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/features/settings/preferences/application/preferences_providers.dart';
import 'package:monthra/features/settings/preferences/domain/theme_preference.dart';

import '../../helpers/app.dart';
import '../../helpers/contrast.dart';
import '../../helpers/frame.dart';

Future<void> pumpCatalog(
  WidgetTester tester, {
  required Size size,
  Brightness brightness = Brightness.light,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.platformBrightnessTestValue = brightness;
  addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
  tester.reduceMotion();
  await tester.pumpMonthraApp(location: AppRoutes.designSystem);
  await tester.pumpAndSettle();
}

/// Checks [guideline] on every screen of the catalog, scrolling a viewport
/// at a time, as a person would see it.
Future<void> expectOnEveryScreen(
  WidgetTester tester,
  AccessibilityGuideline guideline,
) async {
  final position = tester
      .state<ScrollableState>(find.byType(Scrollable).first)
      .position;
  while (true) {
    await expectLater(tester, meetsGuideline(guideline));
    if (position.pixels >= position.maxScrollExtent) break;
    position.jumpTo(
      math.min(
        position.pixels + position.viewportDimension * 0.75,
        position.maxScrollExtent,
      ),
    );
    await tester.pump();
  }
}

void main() {
  for (final brightness in Brightness.values) {
    group('on a phone, ${brightness.name}', () {
      const phone = Size(390, 844);

      testWidgets('every tap target is at least 44 px', (tester) async {
        await pumpCatalog(tester, size: phone, brightness: brightness);
        await expectOnEveryScreen(tester, iOSTapTargetGuideline);
      });

      testWidgets('every tap target has a label', (tester) async {
        await pumpCatalog(tester, size: phone, brightness: brightness);
        await expectOnEveryScreen(tester, labeledTapTargetGuideline);
      });

      // By color, not by pixels: see helpers/contrast.dart.
      testWidgets('every text and icon reads at AA contrast', (tester) async {
        await pumpCatalog(tester, size: phone, brightness: brightness);
        expect(find.byType(RichText), findsWidgets);
        expect(contrastIssues(tester), isEmpty);
      });

      for (final label in ['Toast', 'Error toast']) {
        testWidgets('the ${label.toLowerCase()} meets the guidelines', (
          tester,
        ) async {
          await pumpCatalog(tester, size: phone, brightness: brightness);
          await tester.scrollUntilVisible(
            find.text(label),
            400,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.tap(find.text(label));
          await tester.pumpAndSettle();
          expect(find.bySemanticsLabel('Close'), findsOneWidget);
          await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          expect(contrastIssues(tester), isEmpty);
        });
      }
    });
  }

  testWidgets('on a desktop, targets meet the 24 px WCAG minimum', (
    tester,
  ) async {
    await pumpCatalog(tester, size: const Size(1280, 4000));
    await expectLater(
      tester,
      meetsGuideline(
        const MinimumTapTargetGuideline(
          size: Size(24, 24),
          link:
              'https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum',
        ),
      ),
    );
    expect(find.text('Small'), findsOneWidget);
  });

  testWidgets('copes with twice the text size on a phone', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpCatalog(tester, size: const Size(390, 12000));
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows every section and the default categories', (tester) async {
    await pumpCatalog(tester, size: const Size(1280, 4000));
    for (final section in [
      'Typography',
      'Color roles',
      'Controls',
      'Cards',
      'Amounts',
      'Categories',
      'States',
      'Pages and toasts',
    ]) {
      expect(find.text(section), findsOneWidget);
    }
    expect(find.byType(CategoryBadge), findsNWidgets(sampleCategories.length));
  });

  testWidgets('switches the theme', (tester) async {
    await pumpCatalog(tester, size: const Size(1280, 4000));
    final catalog = find.byType(DesignSystemCatalog);
    expect(tester.themeAt(catalog).brightness, Brightness.light);

    // The test device speaks en-US, so the picker does too.
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(tester.themeAt(catalog).brightness, Brightness.dark);
    expect(
      tester.appContainer.read(preferencesProvider).theme,
      ThemePreference.dark,
    );

    await tester.tap(find.text('System'));
    await tester.pumpAndSettle();
    expect(tester.themeAt(catalog).brightness, Brightness.light);
  });
}
