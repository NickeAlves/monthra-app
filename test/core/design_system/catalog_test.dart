import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/app/app.dart';
import 'package:monthra/core/config/env.dart';
import 'package:monthra/core/design_system/catalog/design_system_catalog.dart';
import 'package:monthra/core/design_system/catalog/sample_categories.dart';
import 'package:monthra/core/design_system/design_system.dart';

import '../../helpers/frame.dart';

final local = Env(
  appEnv: AppEnv.local,
  apiBaseUrl: Uri.parse('http://localhost:8080'),
);

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
  await tester.pumpWidget(MonthraApp(env: local));
  await tester.pumpAndSettle();
}

void main() {
  for (final brightness in Brightness.values) {
    group('on a phone, ${brightness.name}', () {
      const phone = Size(390, 6000);

      testWidgets('every tap target is at least 44 px', (tester) async {
        await pumpCatalog(tester, size: phone, brightness: brightness);
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      });

      testWidgets('every tap target has a label', (tester) async {
        await pumpCatalog(tester, size: phone, brightness: brightness);
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      });

      testWidgets('every text reads at AA contrast', (tester) async {
        await pumpCatalog(tester, size: phone, brightness: brightness);
        await expectLater(tester, meetsGuideline(textContrastGuideline));
      });
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
    ]) {
      expect(find.text(section), findsOneWidget);
    }
    expect(find.byType(CategoryBadge), findsNWidgets(sampleCategories.length));
  });

  testWidgets('switches the theme', (tester) async {
    await pumpCatalog(tester, size: const Size(1280, 4000));
    final catalog = find.byType(DesignSystemCatalog);
    expect(tester.themeAt(catalog).brightness, Brightness.light);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(tester.themeAt(catalog).brightness, Brightness.dark);
    expect(
      tester.widget<DesignSystemCatalog>(catalog).themeMode,
      ThemeMode.dark,
    );

    await tester.tap(find.text('System'));
    await tester.pumpAndSettle();
    expect(tester.themeAt(catalog).brightness, Brightness.light);
  });
}
