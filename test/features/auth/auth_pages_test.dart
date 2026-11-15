import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/app/not_found_page.dart';
import 'package:monthra/app/router.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/core/network/api_providers.dart';
import 'package:monthra/core/network/session_refresher.dart';
import 'package:monthra/core/security/token_store.dart';
import 'package:monthra/features/auth/application/auth_controller.dart';
import 'package:monthra/features/auth/application/auth_state.dart';
import 'package:monthra/features/auth/data/session_hint.dart';
import 'package:monthra/features/auth/presentation/forgot_password_page.dart';
import 'package:monthra/features/auth/presentation/login_page.dart';
import 'package:monthra/features/auth/presentation/mfa_page.dart';
import 'package:monthra/features/auth/presentation/register_page.dart';
import 'package:monthra/features/auth/presentation/reset_password_page.dart';
import 'package:monthra/features/auth/presentation/verify_email_page.dart';
import 'package:monthra/features/home/presentation/home_page.dart';
import 'package:monthra/features/settings/preferences/application/preferences_providers.dart';
import 'package:monthra/features/settings/preferences/domain/app_locale.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../helpers/app.dart';
import '../../helpers/auth_fixtures.dart';
import '../../helpers/fake_api.dart';
import '../../helpers/frame.dart';

/// The test device speaks en-US, and so does the profile in these tests.
final AppLocalizations en = lookupAppLocalizations(const Locale('en'));

Map<String, Object?> enMe() => meJson(locale: 'en-US', theme: 'system');

/// The text input of the field labeled [label].
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

  Future<void> signInForm({
    String email = 'ana@example.com',
    String password = 'a long password',
  }) async {
    await enterText(field(en.authEmailLabel), email);
    await enterText(field(en.authPasswordLabel), password);
    await tapButton(en.authSignInButton);
  }
}

/// The route updates the app reported to the platform (the browser's
/// address bar and history).
List<Map<Object?, Object?>> recordRouteReports(WidgetTester tester) {
  final reports = <Map<Object?, Object?>>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.navigation,
    (call) async {
      if (call.method == 'routeInformationUpdated') {
        reports.add(call.arguments as Map<Object?, Object?>);
      }
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.navigation,
      null,
    ),
  );
  return reports;
}

void main() {
  group('sign-in', () {
    testWidgets('a protected address waits behind sign-in and opens after it', (
      tester,
    ) async {
      final tokens = MemoryTokenStore();
      final api = FakeAdapter(
        (r) => switch (r.path) {
          '/api/v1/auth/login' => Reply.json(sessionJson()),
          '/api/v1/me' => Reply.json(enMe()),
          _ => Reply.problem(404, 'not_found'),
        },
      );
      await tester.pumpMonthraApp(
        api: api,
        tokens: tokens,
        location: '/budgets?month=2026-11',
      );
      await tester.pumpAndSettle();
      expect(find.byType(LoginPage), findsOneWidget);
      expect(
        tester.appLocation.queryParameters['from'],
        '/budgets?month=2026-11',
      );

      await tester.signInForm(email: '  ana@example.com ');

      expect(api.sent.first.data, {
        'email': 'ana@example.com',
        'password': 'a long password',
      });
      expect((await tokens.read())?.refreshToken, 'refresh-1');
      expect(tester.appLocation.toString(), '/budgets?month=2026-11');
      // No budgets page yet.
      expect(find.byType(NotFoundPage), findsOneWidget);
    });

    testWidgets('checks the fields before sending anything', (tester) async {
      final api = silentApi();
      await tester.pumpMonthraApp(api: api);
      await tester.pumpAndSettle();

      await tester.enterText(field(en.authEmailLabel), 'not-an-email');
      await tester.tapButton(en.authSignInButton);

      expect(find.text(en.errorEmailInvalid), findsOneWidget);
      expect(find.text(en.errorFieldRequired), findsOneWidget);
      expect(api.sent, isEmpty);
    });

    testWidgets('a wrong password says so, without telling which', (
      tester,
    ) async {
      await tester.pumpMonthraApp(
        api: FakeAdapter((_) => Reply.problem(401, 'invalid_credentials')),
      );
      await tester.pumpAndSettle();

      await tester.signInForm();

      expect(find.text(en.errorInvalidCredentials), findsOneWidget);
      expect(find.byType(LoginPage), findsOneWidget);
      // The cursor is back in the password: Enter sends again.
      final password = tester.widget<EditableText>(field(en.authPasswordLabel));
      expect(password.focusNode.hasFocus, isTrue);
    });

    testWidgets('an unconfirmed address offers a new link, then waits', (
      tester,
    ) async {
      final api = FakeAdapter(
        (r) => r.path.endsWith('/resend')
            ? const Reply(202)
            : Reply.problem(403, 'email_not_verified'),
      );
      await tester.pumpMonthraApp(api: api);
      await tester.pumpAndSettle();
      await tester.signInForm();
      expect(find.text(en.authEmailNotVerified), findsOneWidget);

      await tester.tapButton(en.authResendVerification);

      expect(api.sent.last.path, '/api/v1/auth/verify-email/resend');
      expect(api.sent.last.data, {'email': 'ana@example.com'});
      expect(
        find.text(en.authVerificationSent('ana@example.com')),
        findsOneWidget,
      );
    });

    testWidgets('a rate limit locks the button and counts down', (
      tester,
    ) async {
      await tester.pumpMonthraApp(
        api: FakeAdapter(
          (_) =>
              Reply.problem(429, 'rate_limited', headers: {'retry-after': '3'}),
        ),
      );
      await tester.pumpAndSettle();
      await tester.signInForm();

      expect(find.text(en.errorRateLimited(3)), findsOneWidget);
      expect(enabled(tester, en.authSignInButton), isFalse);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text(en.errorRateLimited(2)), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.textContaining('Too many attempts'), findsNothing);
      expect(enabled(tester, en.authSignInButton), isTrue);
    });

    testWidgets('a captcha request reads as "try again later"', (tester) async {
      await tester.pumpMonthraApp(
        api: FakeAdapter((_) => Reply.problem(403, 'captcha_required')),
      );
      await tester.pumpAndSettle();
      await tester.signInForm();

      expect(find.text(en.errorCaptcha), findsOneWidget);
    });

    testWidgets('an ended session leaves a notice on the sign-in page', (
      tester,
    ) async {
      var expired = false;
      await tester.pumpMonthraApp(
        tokens: MemoryTokenStore(savedTokens),
        api: FakeAdapter(
          (r) => r.path == '/api/v1/me' && !expired
              ? Reply.json(enMe())
              : Reply.problem(401, 'unauthorized'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);

      // A feature's call gets a 401, and the refresh is refused. (Dio runs
      // on timers, so the call completes while frames are pumped.)
      expired = true;
      final call = expectLater(
        tester.appContainer.read(apiClientProvider).get<Object?>('/accounts'),
        throwsA(isA<ApiProblemException>()),
      );
      await tester.pumpAndSettle();
      await call;

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text(en.authNoticeSessionExpired), findsOneWidget);
    });
  });

  group('two-step verification', () {
    FakeAdapter mfaApi({String verify = 'ok'}) => FakeAdapter(
      (r) => switch (r.path) {
        '/api/v1/auth/login' => Reply.json(challengeJson()),
        '/api/v1/auth/mfa/verify' => switch (verify) {
          'wrong' => Reply.problem(403, 'mfa_code_invalid'),
          'spent' => Reply.problem(401, 'mfa_challenge_invalid'),
          _ => Reply.json(sessionJson(n: 2)),
        },
        '/api/v1/me' => Reply.json(enMe()),
        _ => Reply.problem(404, 'not_found'),
      },
    );

    testWidgets('the sixth digit sends the code and signs in', (tester) async {
      final api = mfaApi();
      await tester.pumpMonthraApp(api: api);
      await tester.pumpAndSettle();
      await tester.signInForm();
      expect(find.byType(MfaPage), findsOneWidget);
      expect(tester.appLocation.path, AppRoutes.mfa);

      // Letters never get in.
      await tester.enterText(field(en.authMfaCodeLabel), '12a345');
      await tester.pumpAndSettle();
      expect(api.count('POST', '/api/v1/auth/mfa/verify'), 0);
      await tester.enterText(field(en.authMfaCodeLabel), '123456');
      await tester.pumpAndSettle();

      expect(api.sent.last.path, '/api/v1/me');
      expect(api.sent.firstWhere((r) => r.path.endsWith('/mfa/verify')).data, {
        'mfaToken': 'mfa-token-secret',
        'code': '123456',
      });
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('a wrong code clears the field and says to wait', (
      tester,
    ) async {
      await tester.pumpMonthraApp(api: mfaApi(verify: 'wrong'));
      await tester.pumpAndSettle();
      await tester.signInForm();
      await tester.enterText(field(en.authMfaCodeLabel), '000000');
      await tester.pumpAndSettle();

      expect(find.text(en.errorMfaCodeInvalid), findsOneWidget);
      expect(
        tester.widget<EditableText>(field(en.authMfaCodeLabel)).controller.text,
        isEmpty,
      );
      expect(find.byType(MfaPage), findsOneWidget);
    });

    testWidgets('a recovery code works too', (tester) async {
      final api = mfaApi();
      await tester.pumpMonthraApp(api: api);
      await tester.pumpAndSettle();
      await tester.signInForm();
      await tester.tapButton(en.authMfaUseRecovery);

      await tester.enterText(field(en.authMfaRecoveryLabel), ' abcd-efgh ');
      await tester.tapButton(en.authMfaVerifyButton);

      expect(api.sent.firstWhere((r) => r.path.endsWith('/mfa/verify')).data, {
        'mfaToken': 'mfa-token-secret',
        'code': 'abcd-efgh',
      });
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('a spent challenge goes back to sign-in with a notice', (
      tester,
    ) async {
      await tester.pumpMonthraApp(api: mfaApi(verify: 'spent'));
      await tester.pumpAndSettle();
      await tester.signInForm();
      await tester.enterText(field(en.authMfaCodeLabel), '000000');
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text(en.authNoticeMfaExpired), findsOneWidget);
    });

    testWidgets('back cancels the challenge', (tester) async {
      await tester.pumpMonthraApp(api: mfaApi());
      await tester.pumpAndSettle();
      await tester.signInForm();

      await tester.tapButton(en.authBackToSignIn);

      expect(find.byType(LoginPage), findsOneWidget);
      expect(
        tester.appContainer.read(authControllerProvider),
        isA<SignedOut>(),
      );
    });

    testWidgets('a reload of the MFA address without a challenge goes back '
        'to sign-in', (tester) async {
      await tester.pumpMonthraApp(location: '/login/mfa?from=%2Fbudgets');
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(tester.appLocation.toString(), '/login?from=%2Fbudgets');
    });
  });

  group('sign-up', () {
    testWidgets('sends the form and asks to check the inbox', (tester) async {
      final api = FakeAdapter((_) => const Reply(202));
      await tester.pumpMonthraApp(api: api, location: AppRoutes.register);
      await tester.pumpAndSettle();

      await tester.enterText(field(en.authNameLabel), ' Ana Souza ');
      await tester.enterText(field(en.authEmailLabel), 'ana@example.com');
      await tester.enterText(field(en.authPasswordLabel), 'a long password');
      await tester.tapButton(en.authRegisterButton);

      expect(api.sent.single.path, '/api/v1/auth/register');
      expect(api.sent.single.data, {
        'name': 'Ana Souza',
        'email': 'ana@example.com',
        'password': 'a long password',
      });
      expect(find.text(en.authCheckInboxTitle), findsOneWidget);
      expect(find.text(en.authResendIn(60)), findsOneWidget);
      expect(enabled(tester, en.authResendIn(60)), isFalse);

      await tester.pump(const Duration(seconds: 60));
      await tester.tapButton(en.authResendVerification);
      expect(api.sent.last.path, '/api/v1/auth/verify-email/resend');
      expect(
        find.text(en.authVerificationSent('ana@example.com')),
        findsOneWidget,
      );
    });

    testWidgets('a short password is caught before sending', (tester) async {
      final api = silentApi();
      await tester.pumpMonthraApp(api: api, location: AppRoutes.register);
      await tester.pumpAndSettle();

      await tester.enterText(field(en.authNameLabel), 'Ana');
      await tester.enterText(field(en.authEmailLabel), 'ana@example.com');
      await tester.enterText(field(en.authPasswordLabel), 'short');
      await tester.tapButton(en.authRegisterButton);

      expect(find.text(en.errorTooShort(10)), findsOneWidget);
      expect(api.sent, isEmpty);
    });

    testWidgets("the server's field errors show under their fields", (
      tester,
    ) async {
      await tester.pumpMonthraApp(
        location: AppRoutes.register,
        api: FakeAdapter(
          (_) => Reply.problem(
            422,
            'validation_failed',
            errors: [
              {'field': 'password', 'code': 'breached'},
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(field(en.authNameLabel), 'Ana');
      await tester.enterText(field(en.authEmailLabel), 'ana@example.com');
      await tester.enterText(field(en.authPasswordLabel), 'password1234');
      await tester.tapButton(en.authRegisterButton);

      expect(find.text(en.errorPasswordBreached), findsOneWidget);
      expect(find.text(en.errorCheckFields), findsOneWidget);

      await tester.enterText(field(en.authPasswordLabel), 'another password');
      await tester.pumpAndSettle();
      expect(find.text(en.errorPasswordBreached), findsNothing);
    });
  });

  testWidgets('forgot password: the same answer for any address', (
    tester,
  ) async {
    final api = FakeAdapter((_) => const Reply(202));
    await tester.pumpMonthraApp(api: api);
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(ShadButton, en.authForgotPasswordLink),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ForgotPasswordPage), findsOneWidget);

    await tester.enterText(field(en.authEmailLabel), 'ana@example.com');
    await tester.tapButton(en.authForgotButton);

    expect(api.sent.single.data, {'email': 'ana@example.com'});
    expect(
      find.text(en.authForgotSentMessage('ana@example.com')),
      findsOneWidget,
    );
  });

  group('reset link', () {
    testWidgets('takes the token out of the address, then sets the password '
        'and signs out everywhere', (tester) async {
      final reports = recordRouteReports(tester);
      final api = FakeAdapter((_) => const Reply(204));
      await tester.pumpMonthraApp(
        api: api,
        location: '/reset-password#token=reset-token',
      );
      await tester.pumpAndSettle();

      expect(find.byType(ResetPasswordPage), findsOneWidget);
      expect(tester.appLocation.toString(), AppRoutes.resetPassword);
      expect(reports.last['uri'], AppRoutes.resetPassword);
      expect(reports.last['replace'], isTrue);
      expect(
        reports.where((r) => '${r['uri']}'.contains('reset-token')),
        everyElement(
          predicate<Map<Object?, Object?>>((r) => r['replace'] == true),
        ),
      );

      await tester.enterText(
        field(en.authPasswordLabel),
        'a new long password',
      );
      await tester.tapButton(en.authResetButton);

      expect(api.sent.single.path, '/api/v1/auth/reset-password');
      expect(api.sent.single.data, {
        'token': 'reset-token',
        'password': 'a new long password',
      });
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text(en.authNoticePasswordReset), findsOneWidget);
    });

    testWidgets('a dead link offers a new one', (tester) async {
      await tester.pumpMonthraApp(
        api: FakeAdapter((_) => Reply.problem(400, 'token_invalid')),
        location: '/reset-password#token=old',
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        field(en.authPasswordLabel),
        'a new long password',
      );
      await tester.tapButton(en.authResetButton);

      expect(find.text(en.authLinkInvalidTitle), findsOneWidget);
      await tester.tapButton(en.authRequestNewLink);
      expect(find.byType(ForgotPasswordPage), findsOneWidget);
    });

    testWidgets('a link without a token asks nothing', (tester) async {
      final api = silentApi();
      await tester.pumpMonthraApp(api: api, location: AppRoutes.resetPassword);
      await tester.pumpAndSettle();

      expect(find.text(en.authLinkInvalidTitle), findsOneWidget);
      expect(api.sent, isEmpty);
    });
  });

  group('confirmation link', () {
    testWidgets('confirms the address once and moves on', (tester) async {
      final api = FakeAdapter((_) => const Reply(204));
      await tester.pumpMonthraApp(
        api: api,
        location: '/verify-email#token=verify-token',
      );
      await tester.pumpAndSettle();
      expect(find.text(en.authVerifiedTitle), findsOneWidget);

      // A rebuild (a language switch) does not send it again.
      await tester.appContainer
          .read(preferencesProvider.notifier)
          .setLocale(AppLocale.esEs);
      await tester.pumpUntilLocalized(tester.appPage, AppLocale.esEs);
      await tester.pumpAndSettle();
      final es = lookupAppLocalizations(const Locale('es'));
      expect(find.text(es.authVerifiedTitle), findsOneWidget);

      expect(api.sent.single.path, '/api/v1/auth/verify-email');
      expect(api.sent.single.data, {'token': 'verify-token'});
      expect(tester.appLocation.toString(), AppRoutes.verifyEmail);

      await tester.tapButton(es.authContinue);
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('a dead link offers to send a new one', (tester) async {
      final api = FakeAdapter(
        (r) => r.path.endsWith('/resend')
            ? const Reply(202)
            : Reply.problem(400, 'token_invalid'),
      );
      await tester.pumpMonthraApp(
        api: api,
        location: '/verify-email#token=old',
      );
      await tester.pumpAndSettle();
      expect(find.byType(VerifyEmailPage), findsOneWidget);
      expect(find.text(en.authLinkInvalidTitle), findsOneWidget);

      await tester.enterText(field(en.authEmailLabel), 'ana@example.com');
      await tester.tapButton(en.authResendVerification);

      expect(api.sent.last.data, {'email': 'ana@example.com'});
      expect(
        find.text(en.authVerificationSent('ana@example.com')),
        findsOneWidget,
      );
    });
  });

  group('signed in', () {
    testWidgets('greets, and signs out to the sign-in page', (tester) async {
      final tokens = MemoryTokenStore(savedTokens);
      final api = FakeAdapter(
        (r) => r.path == '/api/v1/me' ? Reply.json(enMe()) : const Reply(204),
      );
      await tester.pumpMonthraApp(api: api, tokens: tokens);
      await tester.pumpAndSettle();
      expect(find.text(en.homeGreeting('Ana')), findsOneWidget);

      await tester.tapButton(en.homeSignOut);

      expect(api.sent.last.path, '/api/v1/auth/logout');
      expect(await tokens.read(), isNull);
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('the sign-in pages send a signed-in visit home', (
      tester,
    ) async {
      await tester.pumpMonthraApp(
        tokens: MemoryTokenStore(savedTokens),
        api: FakeAdapter((_) => Reply.json(enMe())),
        location: AppRoutes.register,
      );
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(RegisterPage), findsNothing);
    });

    testWidgets('an unknown address offers the way home', (tester) async {
      await tester.pumpMonthraApp(
        tokens: MemoryTokenStore(savedTokens),
        api: FakeAdapter((_) => Reply.json(enMe())),
        location: '/nowhere',
      );
      await tester.pumpAndSettle();
      expect(find.text(en.notFoundTitle), findsOneWidget);

      await tester.tapButton(en.notFoundHome);
      expect(find.byType(HomePage), findsOneWidget);
    });
  });

  group('in a browser', () {
    testWidgets('signs in with cookies: CSRF on every POST, no Bearer, the '
        'hint set', (tester) async {
      final hint = MemorySessionHint();
      final api = FakeAdapter(
        (r) => switch (r.path) {
          '/api/v1/auth/csrf' => Reply.json({'csrfToken': 'csrf-1'}),
          '/api/v1/auth/login' => Reply.json(sessionJson(tokens: false)),
          '/api/v1/me' => Reply.json(enMe()),
          _ => Reply.problem(404, 'not_found'),
        },
      );
      await tester.pumpMonthraApp(
        api: api,
        mode: SessionMode.cookie,
        hint: hint,
        tokens: const NoTokenStore(),
      );
      await tester.pumpAndSettle();
      // No hint: no request at start-up.
      expect(api.sent, isEmpty);

      await tester.signInForm();

      expect(api.paths, [
        'GET /api/v1/auth/csrf',
        'POST /api/v1/auth/login',
        'GET /api/v1/me',
      ]);
      expect(api.sent[1].headers['x-csrf-token'], 'csrf-1');
      expect(
        api.sent.every((r) => !r.headers.containsKey('authorization')),
        isTrue,
      );
      expect(hint.present, isTrue);
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('a later visit with the hint finds the session', (
      tester,
    ) async {
      final api = FakeAdapter((_) => Reply.json(enMe()));
      await tester.pumpMonthraApp(
        api: api,
        mode: SessionMode.cookie,
        hint: MemorySessionHint(present: true),
        tokens: const NoTokenStore(),
      );
      await tester.pumpAndSettle();

      expect(api.paths, ['GET /api/v1/me']);
      expect(find.byType(HomePage), findsOneWidget);
      expect(tester.appContainer.read(authControllerProvider), isA<SignedIn>());
    });
  });

  testWidgets('the start-up check shows a retry when the API is down', (
    tester,
  ) async {
    var online = false;
    await tester.pumpMonthraApp(
      tokens: MemoryTokenStore(savedTokens),
      api: FakeAdapter(
        (_) =>
            online ? Reply.json(enMe()) : Reply.problem(500, 'internal_error'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(en.appUnavailableTitle), findsOneWidget);

    online = true;
    await tester.tapButton(en.appRetry);
    expect(find.byType(HomePage), findsOneWidget);
    expect(
      tester.appContainer.read(authControllerProvider),
      isA<AuthState>().having((s) => s.isSignedIn, 'signed in', isTrue),
    );
  });
}
