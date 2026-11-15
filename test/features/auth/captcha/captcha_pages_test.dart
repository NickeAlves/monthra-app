import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/app/router.dart';
import 'package:monthra/features/auth/captcha/captcha_message.dart';
import 'package:monthra/features/auth/captcha/captcha_request.dart';
import 'package:monthra/features/home/presentation/home_page.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../helpers/app.dart';
import '../../../helpers/auth_fixtures.dart';
import '../../../helpers/captcha.dart';
import '../../../helpers/fake_api.dart';
import '../../../helpers/frame.dart';

final AppLocalizations en = lookupAppLocalizations(const Locale('en'));

Finder field(String label) => find.descendant(
  of: find.widgetWithText(ShadInputFormField, label),
  matching: find.byType(EditableText),
);

Finder button(String label) => find.widgetWithText(ShadButton, label);

bool enabled(WidgetTester tester, String label) =>
    tester.widget<ShadButton>(button(label)).enabled;

extension on WidgetTester {
  Future<void> tapButton(String label) async {
    await ensureVisible(button(label));
    await tap(button(label));
    await pumpAndSettle();
  }

  Future<void> signInForm() async {
    await enterText(field(en.authEmailLabel), 'ana@example.com');
    await enterText(field(en.authPasswordLabel), 'a long password');
    await tapButton(en.authSignInButton);
  }

  /// [captcha] posts [message]; the page reacts (a resend included).
  Future<void> captchaSays(FakeCaptcha captcha, CaptchaMessage message) async {
    captcha.post(message);
    await pumpAndSettle();
  }
}

/// The body of each login the fake server got.
List<Object?> logins(FakeAdapter api) => [
  for (final r in api.sent)
    if (r.path == '/api/v1/auth/login') r.data,
];

/// Motion is off in every test: the skeleton shown while the check loads
/// pulses until the widget is ready.
void main() {
  group('sign-in', () {
    /// Asks for a captcha until a login carries [accepted].
    FakeAdapter api({String accepted = 'token-1'}) => FakeAdapter(
      (r) => switch (r.path) {
        '/api/v1/auth/login' => switch (r.data) {
          {'captchaToken': final String token} when token == accepted =>
            Reply.json(sessionJson()),
          {'captchaToken': _} => Reply.problem(403, 'captcha_invalid'),
          _ => Reply.problem(403, 'captcha_required'),
        },
        '/api/v1/me' => Reply.json(meJson(locale: 'en-US', theme: 'system')),
        _ => Reply.problem(404, 'not_found'),
      },
    );

    testWidgets('shows the check when asked and signs in again by itself '
        'once it passes', (tester) async {
      tester.reduceMotion();
      final server = api();
      final captcha = FakeCaptcha();
      await tester.pumpMonthraApp(
        env: captchaEnv,
        api: server,
        captcha: captcha,
      );
      await tester.pumpAndSettle();
      await tester.signInForm();

      expect(find.text(en.authCaptchaPrompt), findsOneWidget);
      expect(find.text(en.authCaptchaLabel), findsOneWidget);
      expect(find.text(en.authCaptchaHint), findsOneWidget);
      expect(enabled(tester, en.authSignInButton), isFalse);
      expect(captcha.loaded, hasLength(1));
      final request = captcha.loaded.single;
      expect(request.page, Uri.parse('http://localhost:3000/turnstile.html'));
      expect(request.siteKey, '1x00000000000000000000AA');
      expect(request.action, CaptchaAction.login);
      expect(request.languageTag, 'en-US');
      expect(captcha.titles.single, en.authCaptchaLabel);

      await tester.captchaSays(captcha, const CaptchaReady());
      await tester.captchaSays(captcha, const CaptchaSolved('token-1'));

      expect(logins(server), [
        {'email': 'ana@example.com', 'password': 'a long password'},
        {
          'email': 'ana@example.com',
          'password': 'a long password',
          'captchaToken': 'token-1',
        },
      ]);
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('a refused token loads a new check and waits for the '
        'person: no loop against a server refusing every token', (
      tester,
    ) async {
      tester.reduceMotion();
      final server = api(accepted: 'token-3');
      final captcha = FakeCaptcha();
      await tester.pumpMonthraApp(
        env: captchaEnv,
        api: server,
        captcha: captcha,
      );
      await tester.pumpAndSettle();
      await tester.signInForm();
      captcha.solve();
      await tester.pumpAndSettle();

      expect(find.text(en.authCaptchaRejected), findsOneWidget);
      // The send took the token and the refusal started again: a new
      // widget (both restarts may land in one frame).
      expect(captcha.loaded.length, greaterThan(1));
      expect(enabled(tester, en.authSignInButton), isFalse);

      captcha.solve('token-2');
      await tester.pumpAndSettle();
      expect(logins(server), hasLength(2), reason: 'no resend by itself');
      expect(enabled(tester, en.authSignInButton), isTrue);
      await tester.tapButton(en.authSignInButton);
      expect(find.text(en.authCaptchaRejected), findsOneWidget);

      captcha.solve('token-3');
      await tester.pumpAndSettle();
      await tester.tapButton(en.authSignInButton);
      expect(logins(server).map((body) => (body! as Map)['captchaToken']), [
        null,
        'token-1',
        'token-2',
        'token-3',
      ]);
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('after a wrong password the next attempt needs a fresh check', (
      tester,
    ) async {
      tester.reduceMotion();
      final server = FakeAdapter(
        (r) => switch ((r.path, r.data)) {
          ('/api/v1/auth/login', {'captchaToken': _}) => Reply.problem(
            401,
            'invalid_credentials',
          ),
          ('/api/v1/auth/login', _) => Reply.problem(403, 'captcha_required'),
          _ => Reply.problem(404, 'not_found'),
        },
      );
      final captcha = FakeCaptcha();
      await tester.pumpMonthraApp(
        env: captchaEnv,
        api: server,
        captcha: captcha,
      );
      await tester.pumpAndSettle();
      await tester.signInForm();
      captcha.solve();
      await tester.pumpAndSettle();

      expect(find.text(en.errorInvalidCredentials), findsOneWidget);
      expect(find.text(en.authCaptchaHint), findsOneWidget);
      expect(enabled(tester, en.authSignInButton), isFalse);

      // The next token waits for the person: only a refused check resends.
      captcha.solve('token-2');
      await tester.pumpAndSettle();
      expect(logins(server), hasLength(2));
      expect(enabled(tester, en.authSignInButton), isTrue);
      await tester.tapButton(en.authSignInButton);
      expect(logins(server).map((body) => (body! as Map)['captchaToken']), [
        null,
        'token-1',
        'token-2',
      ]);
    });

    testWidgets('a check that fails to load offers a retry', (tester) async {
      tester.reduceMotion();
      final captcha = FakeCaptcha();
      await tester.pumpMonthraApp(
        env: captchaEnv,
        api: api(),
        captcha: captcha,
      );
      await tester.pumpAndSettle();
      await tester.signInForm();
      await tester.captchaSays(captcha, const CaptchaFailed('load'));

      expect(find.text(en.authCaptchaFailed), findsOneWidget);
      await tester.tapButton(en.appRetry);
      expect(captcha.loaded, hasLength(2));
      expect(find.text(en.authCaptchaFailed), findsNothing);

      await tester.captchaSays(captcha, const CaptchaUnsupported());
      expect(find.text(en.authCaptchaUnsupported), findsOneWidget);
      expect(enabled(tester, en.authSignInButton), isFalse);
    });

    testWidgets('an expired token waits for the next one', (tester) async {
      tester.reduceMotion();
      final captcha = FakeCaptcha();
      final server = api(accepted: 'token-2');
      await tester.pumpMonthraApp(
        env: captchaEnv,
        api: server,
        captcha: captcha,
      );
      await tester.pumpAndSettle();
      await tester.signInForm();
      await tester.captchaSays(captcha, const CaptchaReady());
      await tester.captchaSays(captcha, const CaptchaExpired());
      expect(logins(server), hasLength(1));
      expect(enabled(tester, en.authSignInButton), isFalse);

      await tester.captchaSays(captcha, const CaptchaSolved('token-2'));
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('a build without a captcha page keeps "try again later"', (
      tester,
    ) async {
      tester.reduceMotion();
      final captcha = FakeCaptcha();
      await tester.pumpMonthraApp(api: api(), captcha: captcha);
      await tester.pumpAndSettle();
      await tester.signInForm();

      expect(find.text(en.errorCaptcha), findsOneWidget);
      expect(find.text(en.authCaptchaLabel), findsNothing);
      expect(captcha.loaded, isEmpty);
      expect(enabled(tester, en.authSignInButton), isTrue);
    });

    testWidgets('no token goes out before the server asks', (tester) async {
      tester.reduceMotion();
      final server = FakeAdapter(
        (r) => r.path == '/api/v1/auth/login'
            ? Reply.problem(401, 'invalid_credentials')
            : Reply.problem(404, 'not_found'),
      );
      final captcha = FakeCaptcha();
      await tester.pumpMonthraApp(
        env: captchaEnv,
        api: server,
        captcha: captcha,
      );
      await tester.pumpAndSettle();
      await tester.signInForm();

      expect(find.text(en.errorInvalidCredentials), findsOneWidget);
      expect(captcha.loaded, isEmpty);
      expect(logins(server).single, isNot(contains('captchaToken')));
    });
  });

  group('sign-up', () {
    testWidgets('asks for the check of the sign-up form and sends again', (
      tester,
    ) async {
      tester.reduceMotion();
      final server = FakeAdapter(
        (r) => switch ((r.path, r.data)) {
          ('/api/v1/auth/register', {'captchaToken': 'token-1'}) => const Reply(
            202,
          ),
          ('/api/v1/auth/register', _) => Reply.problem(
            403,
            'captcha_required',
          ),
          _ => Reply.problem(404, 'not_found'),
        },
      );
      final captcha = FakeCaptcha();
      await tester.pumpMonthraApp(
        env: captchaEnv,
        api: server,
        captcha: captcha,
        location: AppRoutes.register,
      );
      await tester.pumpAndSettle();
      await tester.enterText(field(en.authNameLabel), 'Ana');
      await tester.enterText(field(en.authEmailLabel), 'ana@example.com');
      await tester.enterText(field(en.authPasswordLabel), 'a long password');
      await tester.tapButton(en.authRegisterButton);

      expect(find.text(en.authCaptchaPrompt), findsOneWidget);
      expect(captcha.loaded.single.action, CaptchaAction.register);
      expect(enabled(tester, en.authRegisterButton), isFalse);

      captcha.solve();
      await tester.pumpAndSettle();
      expect(find.text(en.authCheckInboxTitle), findsOneWidget);
      expect(
        server.sent
            .where((r) => r.path == '/api/v1/auth/register')
            .map((r) => (r.data! as Map)['captchaToken']),
        [null, 'token-1'],
      );
    });
  });
}
