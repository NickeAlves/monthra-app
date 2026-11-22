import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/app/app.dart';
import 'package:monthra/app/routes.dart';
import 'package:monthra/features/settings/data/authenticator_launcher.dart';

import '../../helpers/golden.dart';
import '../../helpers/profile_server.dart';
import 'mfa_pages_test.dart' show FakeLauncher, password, totp;
import 'security_test_helpers.dart';

/// Goldens (pt-BR, motion off) of turning two-step verification on: the
/// QR code step (with the authenticator button on a phone) and the
/// recovery codes.
void main() {
  const scenes = [
    ('mfa_scan_desktop', Size(1280, 1400), false),
    ('mfa_scan_phone', Size(390, 1700), false),
    ('mfa_codes_phone', Size(390, 1300), true),
  ];

  for (final (name, size, codes) in scenes) {
    group(name, () {
      for (final brightness in Brightness.values) {
        testWidgets(brightness.name, tags: ['golden'], (tester) async {
          await pumpSignedIn(
            tester,
            location: AppRoutes.settingsMfaEnable,
            size: size,
            brightness: brightness,
            overrides: [
              authenticatorLauncherProvider.overrideWithValue(
                FakeLauncher(installed: size.width < 640),
              ),
            ],
          );
          await tester.enterText(password(), testPassword);
          await tapAndSettle(tester, button('Continuar'));
          if (codes) {
            await tester.enterText(totp(), testTotp);
            await tester.pumpAndSettle();
          }
          await waitOutToasts(tester);
          // No cursor in the picture.
          FocusManager.instance.primaryFocus?.unfocus();
          await tester.pumpAndSettle();

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
