import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/app/shell/app_shell.dart';
import 'package:monthra/core/security/token_store.dart';
import 'package:monthra/features/auth/data/session_hint.dart';
import 'package:monthra/features/settings/preferences/data/preferences_store.dart';
import 'package:monthra/features/settings/preferences/domain/app_preferences.dart';
import 'package:monthra/features/settings/preferences/domain/theme_preference.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../helpers/app.dart';
import '../../helpers/auth_fixtures.dart';
import '../../helpers/contrast.dart';
import '../../helpers/frame.dart';
import '../../helpers/profile_server.dart';

const Size phone = Size(390, 844);
const Size desktop = Size(1280, 1000);

/// The whole app signed in as [server]'s profile (pt-BR) on a [size]
/// window, opened at [location], with motion off.
Future<ProfileServer> pumpSignedIn(
  WidgetTester tester, {
  required String location,
  ProfileServer? server,
  Size size = desktop,
  Brightness brightness = Brightness.light,
}) async {
  final api = server ?? ProfileServer(me: meJson(theme: brightness.name));
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.reduceMotion();
  await tester.pumpMonthraApp(
    api: api.adapter,
    tokens: MemoryTokenStore(savedTokens),
    hint: MemorySessionHint(present: true),
    location: location,
    store: MemoryPreferencesStore(
      AppPreferences(
        theme: ThemePreference.fromWire(api.preferences['theme']! as String)!,
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(find.byType(AppShell), findsOneWidget);
  return api;
}

/// The button showing [label].
Finder button(String label) =>
    find.ancestor(of: find.text(label), matching: find.byType(ShadButton));

/// Whether the button showing [label] takes taps.
bool enabled(WidgetTester tester, String label) =>
    tester.widget<ShadButton>(button(label).first).enabled;

/// The text field labeled [label].
Finder field(String label) => find.descendant(
  of: find.ancestor(
    of: find.text(label),
    matching: find.byType(ShadInputFormField),
  ),
  matching: find.byType(EditableText),
);

/// Taps [finder] after scrolling it into view, then settles.
Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder.first);
  await tester.pumpAndSettle();
  await tester.tap(finder.first);
  await tester.pump();
  await tester.pumpAndSettle();
}

/// The tap target (44 px on a phone, 24 on a desktop), label and contrast
/// guidelines.
Future<void> expectGuidelines(
  WidgetTester tester, {
  required bool phone,
}) async {
  await expectLater(
    tester,
    meetsGuideline(
      phone
          ? iOSTapTargetGuideline
          : const MinimumTapTargetGuideline(
              size: Size(24, 24),
              link:
                  'https://www.w3.org/WAI/WCAG22/Understanding/'
                  'target-size-minimum',
            ),
    ),
  );
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  expect(contrastIssues(tester), isEmpty);
}
