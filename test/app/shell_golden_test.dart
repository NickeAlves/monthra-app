import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/app/app.dart';
import 'package:monthra/app/shell/app_shell.dart';
import 'package:monthra/core/security/token_store.dart';
import 'package:monthra/features/settings/preferences/data/preferences_store.dart';
import 'package:monthra/features/settings/preferences/domain/app_preferences.dart';
import 'package:monthra/features/settings/preferences/domain/theme_preference.dart';

import '../helpers/app.dart';
import '../helpers/auth_fixtures.dart';
import '../helpers/frame.dart';
import '../helpers/golden.dart';
import '../helpers/profile_server.dart';

/// Goldens (pt-BR, motion off) of the shell at each breakpoint and of the
/// whole settings page (two-step verification off, then on with few
/// recovery codes left), signed in with the profile's theme.
void main() {
  const scenes = [
    ('shell_desktop', Size(1280, 800), '/', false, false),
    ('shell_tablet', Size(800, 1024), '/', false, false),
    ('shell_phone', Size(390, 844), '/', false, false),
    ('shell_phone_more', Size(390, 844), '/', true, false),
    ('settings_desktop', Size(1280, 1900), '/settings', false, false),
    ('settings_phone', Size(390, 2900), '/settings', false, false),
    ('settings_mfa_desktop', Size(1280, 1900), '/settings', false, true),
    ('settings_mfa_phone', Size(390, 2900), '/settings', false, true),
  ];

  for (final (name, size, location, more, mfa) in scenes) {
    group(name, () {
      for (final brightness in Brightness.values) {
        testWidgets(brightness.name, tags: ['golden'], (tester) async {
          tester.view
            ..physicalSize = size
            ..devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          tester.reduceMotion();
          final theme = ThemePreference.fromWire(brightness.name)!;
          final me = meJson(theme: brightness.name);
          await tester.pumpMonthraApp(
            api: ProfileServer(
              me: mfa
                  ? {
                      ...me,
                      'mfa': {'enabled': true, 'recoveryCodesRemaining': 2},
                    }
                  : me,
            ).adapter,
            tokens: MemoryTokenStore(savedTokens),
            location: location,
            store: MemoryPreferencesStore(AppPreferences(theme: theme)),
          );
          await tester.pumpAndSettle();
          expect(find.byType(AppShell), findsOneWidget);
          if (more) {
            await tester.tap(find.text('Mais'));
            await tester.pumpAndSettle();
          }

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
