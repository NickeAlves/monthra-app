import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/app/app.dart';
import 'package:monthra/core/config/env.dart';
import 'package:monthra/core/design_system/catalog/design_system_catalog.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../helpers/frame.dart';

void main() {
  Env envFor(AppEnv appEnv) =>
      Env(appEnv: appEnv, apiBaseUrl: Uri.parse('https://api.example.com'));

  for (final appEnv in [AppEnv.local, AppEnv.staging]) {
    testWidgets('shows the design system catalog in ${appEnv.name}', (
      tester,
    ) async {
      // The catalog's skeletons would keep pumpAndSettle busy.
      tester.reduceMotion();
      await tester.pumpWidget(MonthraApp(env: envFor(appEnv)));
      await tester.pumpAndSettle();

      expect(find.byType(DesignSystemCatalog), findsOneWidget);
      expect(find.text(appEnv.name), findsOneWidget);
      expect(find.byType(PlaceholderPage), findsNothing);
    });
  }

  testWidgets('shows the brand page in production', (tester) async {
    await tester.pumpWidget(MonthraApp(env: envFor(AppEnv.production)));
    await tester.pumpAndSettle();

    expect(find.byType(PlaceholderPage), findsOneWidget);
    expect(find.text('Monthra'), findsOneWidget);
    expect(find.byType(DesignSystemCatalog), findsNothing);
  });

  testWidgets('uses the Monthra theme and follows a dark system', (
    tester,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(MonthraApp(env: envFor(AppEnv.production)));
    await tester.pumpAndSettle();

    final theme = tester.themeAt(find.byType(PlaceholderPage));
    expect(theme.brightness, Brightness.dark);
    expect(theme.textTheme.family, 'Inter');
    expect(theme.colorScheme.background, const Color(0xFF141414));
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is SvgPicture &&
            w.bytesLoader.toString().contains('monthra-simbolo-branco.svg'),
      ),
      findsOneWidget,
    );
  });
}
