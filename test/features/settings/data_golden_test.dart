import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/app/app.dart';
import 'package:monthra/app/routes.dart';
import 'package:monthra/core/files/file_saver.dart';

import '../../helpers/auth_fixtures.dart';
import '../../helpers/file_saver.dart';
import '../../helpers/golden.dart';
import '../../helpers/profile_server.dart';
import 'data_pages_test.dart' show deleteSubmit, password;
import 'security_test_helpers.dart';

enum _Scene { exportForm, exportReady, deleteForm, deleteDialog }

/// Goldens (pt-BR, motion off) of the data pages: the export with two-step
/// verification on, its archive ready after a cancelled save, the deletion
/// page and its last question.
void main() {
  const scenes = [
    ('export_desktop', Size(1280, 900), _Scene.exportForm),
    ('export_ready_phone', Size(390, 844), _Scene.exportReady),
    ('delete_desktop', Size(1280, 900), _Scene.deleteForm),
    ('delete_dialog_phone', Size(390, 960), _Scene.deleteDialog),
  ];

  for (final (name, size, scene) in scenes) {
    group(name, () {
      for (final brightness in Brightness.values) {
        testWidgets(brightness.name, tags: ['golden'], (tester) async {
          final exporting =
              scene == _Scene.exportForm || scene == _Scene.exportReady;
          await pumpSignedIn(
            tester,
            location: exporting
                ? AppRoutes.settingsExport
                : AppRoutes.settingsDeleteAccount,
            size: size,
            brightness: brightness,
            server: ProfileServer(
              me: meJson(
                mfa: scene == _Scene.exportForm,
                theme: brightness.name,
              ),
            ),
            overrides: [
              fileSaverProvider.overrideWithValue(
                FakeFileSaver(outcome: SaveOutcome.cancelled),
              ),
            ],
          );
          switch (scene) {
            case _Scene.exportReady:
              await tester.enterText(password(), testPassword);
              await tapAndSettle(tester, button('Exportar'));
            case _Scene.deleteDialog:
              await tester.enterText(password(), testPassword);
              await tapAndSettle(tester, button(deleteSubmit));
            case _Scene.exportForm || _Scene.deleteForm:
              break;
          }
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
