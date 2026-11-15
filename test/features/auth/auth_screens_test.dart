import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/app/app.dart';
import 'package:monthra/app/router.dart';
import 'package:monthra/features/auth/presentation/mfa_page.dart';
import 'package:monthra/features/settings/preferences/data/preferences_store.dart';
import 'package:monthra/features/settings/preferences/domain/app_locale.dart';
import 'package:monthra/features/settings/preferences/domain/app_preferences.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../helpers/app.dart';
import '../../helpers/auth_fixtures.dart';
import '../../helpers/contrast.dart';
import '../../helpers/fake_api.dart';
import '../../helpers/frame.dart';
import '../../helpers/golden.dart';

/// The sign-in screens as people see them: tap targets, labels, contrast,
/// large text, and goldens (pt-BR) of the sign-in and two-step pages.
void main() {
  const phone = Size(390, 844);
  // Tall enough that the longest form fits without scrolling.
  const tallPhone = Size(390, 1200);
  const desktop = Size(1280, 800);
  final pt = lookupAppLocalizations(const Locale('pt'));

  /// The app at [location] on a [size] screen, in pt-BR, motion off.
  Future<void> pumpScreen(
    WidgetTester tester,
    String location, {
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
    await tester.pumpMonthraApp(
      location: location == AppRoutes.mfa ? AppRoutes.login : location,
      store: MemoryPreferencesStore(
        const AppPreferences(locale: AppLocale.ptBr),
      ),
      api: FakeAdapter(
        (r) => r.path.endsWith('/auth/login')
            ? Reply.json(challengeJson())
            : Reply.problem(404, 'not_found'),
      ),
    );
    await tester.pumpAndSettle();
    if (location == AppRoutes.mfa) {
      // The two-step page needs a challenge: a sign-in asks for it.
      await tester.enterText(find.byType(EditableText).first, 'a@b.co');
      await tester.enterText(find.byType(EditableText).last, 'a password');
      await tester.tap(find.widgetWithText(ShadButton, pt.authSignInButton));
      await tester.pumpAndSettle();
      expect(find.byType(MfaPage), findsOneWidget);
    }
  }

  const screens = [AppRoutes.login, AppRoutes.register, AppRoutes.mfa];

  for (final location in screens) {
    group(location, () {
      for (final brightness in Brightness.values) {
        testWidgets('on a phone, ${brightness.name}: 44 px labeled targets '
            'and AA contrast', (tester) async {
          final semantics = tester.ensureSemantics();
          await pumpScreen(
            tester,
            location,
            size: tallPhone,
            brightness: brightness,
          );
          await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          expect(contrastIssues(tester), isEmpty);
          semantics.dispose();
        });

        testWidgets('on a desktop, ${brightness.name}: AA contrast on the '
            'brand panel too', (tester) async {
          await pumpScreen(
            tester,
            location,
            size: desktop,
            brightness: brightness,
          );
          expect(find.text(pt.authTagline), findsOneWidget);
          expect(contrastIssues(tester), isEmpty);
        });
      }

      testWidgets('copes with twice the text size on a phone', (tester) async {
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await pumpScreen(tester, location, size: phone);
        expect(tester.takeException(), isNull);
      });
    });
  }

  for (final (name, location, size) in [
    ('login_phone', AppRoutes.login, phone),
    ('login_desktop', AppRoutes.login, desktop),
    ('mfa_phone', AppRoutes.mfa, phone),
  ]) {
    group(name, () {
      for (final brightness in Brightness.values) {
        testWidgets(brightness.name, tags: ['golden'], (tester) async {
          await pumpScreen(
            tester,
            location,
            size: size,
            brightness: brightness,
          );
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
