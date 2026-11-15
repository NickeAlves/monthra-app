import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/app/app.dart';
import 'package:monthra/core/config/env.dart';

void main() {
  Env envFor(AppEnv appEnv) =>
      Env(appEnv: appEnv, apiBaseUrl: Uri.parse('https://api.example.com'));

  testWidgets('shows the brand and the environment outside production', (
    tester,
  ) async {
    await tester.pumpWidget(MonthraApp(env: envFor(AppEnv.staging)));
    await tester.pumpAndSettle();

    expect(find.text('Monthra'), findsOneWidget);
    expect(find.text('staging'), findsOneWidget);
  });

  testWidgets('hides the environment in production', (tester) async {
    await tester.pumpWidget(MonthraApp(env: envFor(AppEnv.production)));
    await tester.pumpAndSettle();

    expect(find.text('Monthra'), findsOneWidget);
    expect(find.text('production'), findsNothing);
  });

  testWidgets('draws the white symbol on a dark system theme', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(MonthraApp(env: envFor(AppEnv.local)));
    await tester.pumpAndSettle();

    expect(find.text('local'), findsOneWidget);
    final page = tester.element(find.byType(PlaceholderPage));
    expect(MediaQuery.platformBrightnessOf(page), Brightness.dark);
  });
}
