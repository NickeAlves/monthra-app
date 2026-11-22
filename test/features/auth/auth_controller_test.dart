import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/app/overrides.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/core/network/api_problem.dart';
import 'package:monthra/core/network/api_providers.dart';
import 'package:monthra/core/network/session_refresher.dart';
import 'package:monthra/core/security/auth_tokens.dart';
import 'package:monthra/core/security/token_store.dart';
import 'package:monthra/features/auth/application/auth_controller.dart';
import 'package:monthra/features/auth/application/auth_state.dart';
import 'package:monthra/features/auth/data/session_hint.dart';
import 'package:monthra/features/settings/preferences/application/preferences_providers.dart';
import 'package:monthra/features/settings/preferences/data/preferences_store.dart';
import 'package:monthra/features/settings/preferences/domain/app_locale.dart';
import 'package:monthra/features/settings/preferences/domain/app_preferences.dart';
import 'package:monthra/features/settings/preferences/domain/theme_preference.dart';

import '../../helpers/app.dart';
import '../../helpers/auth_fixtures.dart';
import '../../helpers/fake_api.dart';

/// A container wired as the app, on [api].
({ProviderContainer container, MemoryPreferencesStore prefs}) boot(
  FakeAdapter api, {
  SessionMode mode = SessionMode.bearer,
  TokenStore? tokens,
  SessionHint? hint,
}) {
  final prefs = MemoryPreferencesStore();
  final container = ProviderContainer.test(
    overrides: [
      ...appOverrides(env: localEnv, preferences: prefs),
      httpAdapterProvider.overrideWithValue(api),
      sessionModeProvider.overrideWithValue(mode),
      tokenStoreProvider.overrideWithValue(tokens ?? MemoryTokenStore()),
      sessionHintProvider.overrideWithValue(hint ?? MemorySessionHint()),
    ],
  );
  return (container: container, prefs: prefs);
}

/// Reads the controller and waits until the start-up check settles.
Future<AuthState> settled(ProviderContainer container) async {
  container.listen(authControllerProvider, (_, _) {});
  for (var i = 0; i < 50; i++) {
    final state = container.read(authControllerProvider);
    if (state is! AuthBooting) return state;
    await Future<void>.delayed(Duration.zero);
  }
  fail('the start-up check never settled');
}

AuthController controllerOf(ProviderContainer c) =>
    c.read(authControllerProvider.notifier);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('start-up', () {
    test('a device without tokens opens signed out, asking nothing', () async {
      final api = silentApi();
      final c = boot(api).container;
      expect(await settled(c), isA<SignedOut>());
      expect(api.sent, isEmpty);
    });

    test('a device with tokens loads the profile, whose language and theme '
        'win over the local ones', () async {
      final api = FakeAdapter(
        (r) => r.path.endsWith('/me')
            ? Reply.json(meJson(locale: 'es-ES'))
            : Reply.problem(404, 'not_found'),
      );
      final (:container, :prefs) = boot(
        api,
        tokens: MemoryTokenStore(savedTokens),
      );
      final state = await settled(container);

      expect(state, isA<SignedIn>());
      expect((state as SignedIn).me.name, 'Ana');
      expect(api.paths, ['GET /api/v1/me']);
      expect(api.sent.single.headers['authorization'], 'Bearer access-0');
      expect(
        container.read(preferencesProvider),
        const AppPreferences(
          locale: AppLocale.esEs,
          theme: ThemePreference.dark,
        ),
      );
      expect(prefs.read().locale, AppLocale.esEs);
    });

    test(
      'a browser without the hint opens signed out, asking nothing',
      () async {
        final api = silentApi();
        final c = boot(api, mode: SessionMode.cookie).container;
        expect(c.read(authControllerProvider), isA<SignedOut>());
        expect(await settled(c), isA<SignedOut>());
        expect(api.sent, isEmpty);
      },
    );

    test('a browser with the hint whose session ended signs out with a '
        'notice and drops the hint', () async {
      final hint = MemorySessionHint(present: true);
      final api = FakeAdapter(
        (r) => switch (r.path) {
          '/api/v1/auth/csrf' => Reply.json({'csrfToken': 'csrf'}),
          _ => Reply.problem(401, 'unauthorized'),
        },
      );
      final c = boot(api, mode: SessionMode.cookie, hint: hint).container;
      final state = await settled(c);

      expect(state, isA<SignedOut>());
      expect((state as SignedOut).notice, AuthNotice.sessionExpired);
      expect(hint.present, isFalse);
      expect(api.paths, [
        'GET /api/v1/me',
        'GET /api/v1/auth/csrf',
        'POST /api/v1/auth/refresh',
      ]);
    });

    test('an unreachable API is unavailable, and retry checks again', () {
      fakeAsync((async) {
        var online = false;
        final api = FakeAdapter(
          (r) => online ? Reply.json(meJson()) : Reply.unreachable,
        );
        final c = boot(api, tokens: MemoryTokenStore(savedTokens)).container
          ..listen(authControllerProvider, (_, _) {});
        // The read is sent three times (two retries, 1.5 s of backoff).
        async.elapse(const Duration(seconds: 3));
        final state = c.read(authControllerProvider);
        expect(state, isA<AuthUnavailable>());
        expect((state as AuthUnavailable).error, isA<NetworkException>());
        expect(api.paths, List.filled(3, 'GET /api/v1/me'));

        online = true;
        controllerOf(c).retry();
        expect(c.read(authControllerProvider), isA<AuthBooting>());
        async.elapse(const Duration(milliseconds: 10));
        expect(c.read(authControllerProvider), isA<SignedIn>());
      });
    });
  });

  group('sign-in', () {
    test('saves the tokens, then loads the profile', () async {
      final tokens = MemoryTokenStore();
      AuthTokens? savedWhenAskedForMe;
      final api = FakeAdapter((r) async {
        if (r.path.endsWith('/auth/login')) return Reply.json(sessionJson());
        savedWhenAskedForMe = await tokens.read();
        return Reply.json(meJson());
      });
      final c = boot(api, tokens: tokens).container;
      await settled(c);

      await controllerOf(c).signIn(email: 'ana@example.com', password: 'pw');

      expect(c.read(authControllerProvider), isA<SignedIn>());
      expect(savedWhenAskedForMe?.accessToken, 'access-1');
      expect(api.sent.first.data, {
        'email': 'ana@example.com',
        'password': 'pw',
      });
      expect(api.sent.first.headers.containsKey('authorization'), isFalse);
    });

    test('a browser keeps no token and sets the hint', () async {
      final hint = MemorySessionHint();
      final api = FakeAdapter(
        (r) => switch (r.path) {
          '/api/v1/auth/csrf' => Reply.json({'csrfToken': 'csrf'}),
          '/api/v1/auth/login' => Reply.json(sessionJson(tokens: false)),
          _ => Reply.json(meJson()),
        },
      );
      final c = boot(api, mode: SessionMode.cookie, hint: hint).container;
      await settled(c);

      await controllerOf(c).signIn(email: 'ana@example.com', password: 'pw');

      expect(c.read(authControllerProvider), isA<SignedIn>());
      expect(hint.present, isTrue);
    });

    test('a refused password throws its problem and changes nothing', () async {
      final api = FakeAdapter((_) => Reply.problem(401, 'invalid_credentials'));
      final c = boot(api).container;
      await settled(c);

      await expectLater(
        controllerOf(c).signIn(email: 'ana@example.com', password: 'nope'),
        throwsA(
          isA<ApiProblemException>().having(
            (e) => e.code,
            'code',
            ProblemCode.invalidCredentials,
          ),
        ),
      );
      expect(c.read(authControllerProvider), isA<SignedOut>());
      // A public route: the 401 is the answer, not a session to renew.
      expect(api.paths, ['POST /api/v1/auth/login']);
    });

    test('two-step verification waits for the code', () async {
      final tokens = MemoryTokenStore();
      final api = FakeAdapter(
        (r) => switch (r.path) {
          '/api/v1/auth/login' => Reply.json(challengeJson()),
          '/api/v1/auth/mfa/verify' => Reply.json(sessionJson(n: 2)),
          _ => Reply.json(meJson()),
        },
      );
      final c = boot(api, tokens: tokens).container;
      await settled(c);

      await controllerOf(c).signIn(email: 'ana@example.com', password: 'pw');
      final pending = c.read(authControllerProvider);
      expect(pending, isA<AwaitingMfa>());
      expect(await tokens.read(), isNull);

      await controllerOf(c).verifyMfa('123456');
      expect(c.read(authControllerProvider), isA<SignedIn>());
      expect((await tokens.read())?.accessToken, 'access-2');
      expect(api.sent[1].data, {
        'mfaToken': 'mfa-token-secret',
        'code': '123456',
      });
    });

    test('a wrong code throws and keeps the challenge', () async {
      final api = FakeAdapter(
        (r) => r.path.endsWith('/auth/login')
            ? Reply.json(challengeJson())
            : Reply.problem(403, 'mfa_code_invalid'),
      );
      final c = boot(api).container;
      await settled(c);
      await controllerOf(c).signIn(email: 'ana@example.com', password: 'pw');

      await expectLater(
        controllerOf(c).verifyMfa('000000'),
        throwsA(isA<ApiProblemException>()),
      );
      expect(c.read(authControllerProvider), isA<AwaitingMfa>());
    });

    test('a spent challenge goes back to sign-in with a notice', () async {
      final api = FakeAdapter(
        (r) => r.path.endsWith('/auth/login')
            ? Reply.json(challengeJson())
            : Reply.problem(401, 'mfa_challenge_invalid'),
      );
      final c = boot(api).container;
      await settled(c);
      await controllerOf(c).signIn(email: 'ana@example.com', password: 'pw');

      await controllerOf(c).verifyMfa('000000');
      final state = c.read(authControllerProvider);
      expect(state, isA<SignedOut>());
      expect((state as SignedOut).notice, AuthNotice.mfaExpired);
    });

    test('the challenge expires on its own after expiresIn', () {
      fakeAsync((async) {
        final api = FakeAdapter((_) => Reply.json(challengeJson(expiresIn: 5)));
        final c = boot(api).container
          ..listen(authControllerProvider, (_, _) {});
        async.elapse(Duration.zero);
        unawaited(
          controllerOf(c).signIn(email: 'ana@example.com', password: 'pw'),
        );
        async.elapse(const Duration(milliseconds: 10));
        expect(c.read(authControllerProvider), isA<AwaitingMfa>());

        async.elapse(const Duration(seconds: 5));
        final state = c.read(authControllerProvider);
        expect(state, isA<SignedOut>());
        expect((state as SignedOut).notice, AuthNotice.mfaExpired);
      });
    });
  });

  group('sign-out', () {
    Future<ProviderContainer> signedIn(
      FakeAdapter Function() api, {
      SessionMode mode = SessionMode.bearer,
      TokenStore? tokens,
      SessionHint? hint,
    }) async {
      final c = boot(api(), mode: mode, tokens: tokens, hint: hint).container;
      expect(await settled(c), isA<SignedIn>());
      return c;
    }

    test(
      'a device forgets its tokens even when the server cannot be told',
      () async {
        final tokens = MemoryTokenStore(savedTokens);
        final c = await signedIn(
          () => FakeAdapter(
            (r) => r.path.endsWith('/me')
                ? Reply.json(meJson())
                : Reply.unreachable,
          ),
          tokens: tokens,
        );

        await controllerOf(c).signOut();

        expect(c.read(authControllerProvider), isA<SignedOut>());
        expect(await tokens.read(), isNull);
      },
    );

    test('a browser stays signed in when the server cannot be told', () async {
      final hint = MemorySessionHint(present: true);
      final c = await signedIn(
        () => FakeAdapter(
          (r) => switch (r.path) {
            '/api/v1/me' => Reply.json(meJson()),
            '/api/v1/auth/csrf' => Reply.json({'csrfToken': 'csrf'}),
            _ => Reply.unreachable,
          },
        ),
        mode: SessionMode.cookie,
        hint: hint,
      );

      await expectLater(
        controllerOf(c).signOut(),
        throwsA(isA<NetworkException>()),
      );
      expect(c.read(authControllerProvider), isA<SignedIn>());
      expect(hint.present, isTrue);
    });

    test('a browser signs out and drops the hint', () async {
      final hint = MemorySessionHint(present: true);
      final c = await signedIn(
        () => FakeAdapter(
          (r) => switch (r.path) {
            '/api/v1/me' => Reply.json(meJson()),
            '/api/v1/auth/csrf' => Reply.json({'csrfToken': 'csrf'}),
            _ => const Reply(204),
          },
        ),
        mode: SessionMode.cookie,
        hint: hint,
      );

      await controllerOf(c).signOut();

      expect(c.read(authControllerProvider), isA<SignedOut>());
      expect(hint.present, isFalse);
    });

    test(
      'a session the client could not renew signs out with a notice',
      () async {
        final tokens = MemoryTokenStore(savedTokens);
        var expired = false;
        final c = await signedIn(
          () => FakeAdapter(
            (r) => switch (r.path) {
              '/api/v1/me' when !expired => Reply.json(meJson()),
              _ => Reply.problem(401, 'unauthorized'),
            },
          ),
          tokens: tokens,
        );

        // Any call of a feature: its 401, then a refused refresh.
        expired = true;
        await expectLater(
          c.read(apiClientProvider).get<Object?>('/accounts'),
          throwsA(isA<ApiProblemException>()),
        );
        await Future<void>.delayed(Duration.zero);

        final state = c.read(authControllerProvider);
        expect(state, isA<SignedOut>());
        expect((state as SignedOut).notice, AuthNotice.sessionExpired);
        expect(await tokens.read(), isNull);
      },
    );

    test('a password reset ends the session with its own notice', () async {
      final tokens = MemoryTokenStore(savedTokens);
      final c = await signedIn(
        () => FakeAdapter((_) => Reply.json(meJson())),
        tokens: tokens,
      );

      await controllerOf(c).sessionEnded(AuthNotice.passwordReset);

      final state = c.read(authControllerProvider);
      expect((state as SignedOut).notice, AuthNotice.passwordReset);
      expect(await tokens.read(), isNull);
    });
  });

  group('profile updates', () {
    Future<ProviderContainer> signedIn() async {
      final api = FakeAdapter(
        (r) => r.path.endsWith('/me')
            ? Reply.json(meJson())
            : Reply.problem(404, 'not_found'),
      );
      final c = boot(api, tokens: MemoryTokenStore(savedTokens)).container;
      expect(await settled(c), isA<SignedIn>());
      return c;
    }

    test('apply to the person signed in', () async {
      final c = await signedIn();
      controllerOf(c).updateMe('u1', (me) => me.copyWith(name: 'Bia'));
      expect((c.read(authControllerProvider) as SignedIn).me.name, 'Bia');
    });

    test('for someone else, or once signed out, change nothing', () async {
      final c = await signedIn();
      final before = c.read(authControllerProvider);
      controllerOf(c).updateMe('u2', (me) => me.copyWith(name: 'Bia'));
      expect(c.read(authControllerProvider), same(before));

      // An update that swaps the person is refused too.
      controllerOf(c)
          .updateMe('u1', (me) => me.copyWith(id: 'u2', name: 'Bia'));
      expect(c.read(authControllerProvider), same(before));

      await controllerOf(c).signOut();
      controllerOf(c).updateMe('u1', (me) => me.copyWith(name: 'Bia'));
      expect(c.read(authControllerProvider), isA<SignedOut>());
    });

    test('never touch the local language and theme', () async {
      final c = await signedIn();
      final local = c.read(preferencesProvider);
      controllerOf(c).updateMe(
        'u1',
        (me) => me.copyWith(
          preferences: me.preferences.copyWith(theme: 'light', locale: 'en-US'),
        ),
      );
      expect(c.read(preferencesProvider), local);
    });

    test('refreshProfile reads the profile again, and only that', () async {
      var profile = meJson();
      final api = FakeAdapter(
        (r) => r.path.endsWith('/me')
            ? Reply.json(profile)
            : Reply.problem(404, 'not_found'),
      );
      final c = boot(api, tokens: MemoryTokenStore(savedTokens)).container;
      expect(await settled(c), isA<SignedIn>());
      final local = c.read(preferencesProvider);

      profile = meJson(mfa: true, theme: 'light');
      await controllerOf(c).refreshProfile();

      final me = (c.read(authControllerProvider) as SignedIn).me;
      expect(me.mfa.enabled, isTrue);
      expect(me.preferences.theme, 'light');
      expect(c.read(preferencesProvider), local, reason: 'not a sign-in');
      expect(api.count('GET', '/api/v1/me'), 2);
    });

    test(
      'refreshProfile throws a failure and asks nothing signed out',
      () async {
        var down = false;
        final api = FakeAdapter(
          (r) => down
              ? Reply.problem(503, 'service_unavailable')
              : r.path.endsWith('/me')
              ? Reply.json(meJson())
              : Reply.problem(404, 'not_found'),
        );
        final c = boot(api, tokens: MemoryTokenStore(savedTokens)).container;
        expect(await settled(c), isA<SignedIn>());
        down = true;
        await expectLater(
          controllerOf(c).refreshProfile(),
          throwsA(isA<ApiProblemException>()),
        );
        expect(c.read(authControllerProvider), isA<SignedIn>());

        down = false;
        await controllerOf(c).signOut();
        final asked = api.sent.length;
        await controllerOf(c).refreshProfile();
        expect(api.sent.length, asked);
      },
    );
  });
}
