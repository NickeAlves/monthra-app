import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/app/app.dart';
import 'package:monthra/core/security/token_store.dart';
import 'package:monthra/features/dashboard/presentation/dashboard_page.dart';
import 'package:monthra/features/settings/preferences/data/preferences_store.dart';
import 'package:monthra/features/settings/preferences/domain/app_locale.dart';
import 'package:monthra/features/settings/preferences/domain/app_preferences.dart';
import 'package:monthra/features/settings/preferences/domain/theme_preference.dart';

import '../../helpers/app.dart';
import '../../helpers/auth_fixtures.dart';
import '../../helpers/frame.dart';
import '../../helpers/golden.dart';
import '../../helpers/profile_server.dart';

/// Goldens (pt-BR, motion off) of the whole dashboard with the demo data
/// (reais in full, dollars compact) at each breakpoint, and of a person with
/// no account yet, in the profile's theme.
void main() {
  const scenes = [
    ('dashboard_desktop', Size(1280, 1500), false),
    ('dashboard_tablet', Size(800, 2500), false),
    ('dashboard_phone', Size(390, 2950), false),
    ('dashboard_empty_phone', Size(390, 844), true),
  ];

  for (final (name, size, empty) in scenes) {
    group(name, () {
      for (final brightness in Brightness.values) {
        testWidgets(brightness.name, tags: ['golden'], (tester) async {
          tester.view
            ..physicalSize = size
            ..devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          tester.reduceMotion();
          final server = ProfileServer(
            me: meJson(theme: brightness.name),
            accounts: empty ? const [] : null,
            summaryFor: empty
                ? (month) => {
                    'month': month.toString(),
                    'asOf': '2026-11-23',
                    'currencies': <Object?>[],
                    'accounts': <Object?>[],
                  }
                : null,
          );
          await tester.pumpMonthraApp(
            api: server.adapter,
            tokens: MemoryTokenStore(savedTokens),
            store: MemoryPreferencesStore(
              AppPreferences(
                locale: AppLocale.ptBr,
                theme: ThemePreference.fromWire(brightness.name)!,
              ),
            ),
          );
          for (var i = 0; i < 5; i++) {
            await tester.pumpAndSettle();
            await tester.pump(Duration.zero);
          }
          expect(find.byType(DashboardPage), findsOneWidget);
          expect(tester.takeException(), isNull);

          if (!goldensRunHere) {
            markTestSkipped('image comparison runs on Linux only (see README)');
            return;
          }
          await expectLater(
            find.byType(MonthraApp),
            matchesGoldenFile('goldens/${name}_${brightness.name}.png'),
          );
        });
      }
    });
  }
}
