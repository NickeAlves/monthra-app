import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/app/overrides.dart';
import 'package:monthra/core/money/currency.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/core/network/api_problem.dart';
import 'package:monthra/core/network/api_providers.dart';
import 'package:monthra/core/network/session_refresher.dart';
import 'package:monthra/core/security/token_store.dart';
import 'package:monthra/features/auth/application/auth_controller.dart';
import 'package:monthra/features/auth/application/auth_state.dart';
import 'package:monthra/features/auth/data/models/me.dart';
import 'package:monthra/features/auth/data/session_hint.dart';
import 'package:monthra/features/settings/application/profile_controller.dart';
import 'package:monthra/features/settings/domain/preferences_patch.dart';
import 'package:monthra/features/settings/preferences/application/preferences_providers.dart';
import 'package:monthra/features/settings/preferences/data/preferences_store.dart';
import 'package:monthra/features/settings/preferences/domain/app_locale.dart';
import 'package:monthra/features/settings/preferences/domain/app_preferences.dart';
import 'package:monthra/features/settings/preferences/domain/theme_preference.dart';

import '../../helpers/app.dart';
import '../../helpers/auth_fixtures.dart';
import '../../helpers/fake_api.dart';
import '../../helpers/profile_server.dart';

typedef Booted = ({ProviderContainer container, MemoryPreferencesStore prefs});

/// A container wired as the app on [server]; signed in from saved tokens
/// unless [signedIn] is false. The local preferences start as [local].
Future<Booted> boot(
  ProfileServer server, {
  bool signedIn = true,
  AppPreferences local = const AppPreferences(),
}) async {
  final prefs = MemoryPreferencesStore(local);
  final container =
      ProviderContainer.test(
          overrides: [
            ...appOverrides(env: localEnv, preferences: prefs),
            httpAdapterProvider.overrideWithValue(server.adapter),
            sessionModeProvider.overrideWithValue(SessionMode.bearer),
            tokenStoreProvider.overrideWithValue(
              MemoryTokenStore(signedIn ? savedTokens : null),
            ),
            sessionHintProvider.overrideWithValue(MemorySessionHint()),
          ],
        )
        // Alive before the session settles, as in the app.
        ..listen(profileControllerProvider, (_, _) {})
        ..listen(authControllerProvider, (_, _) {});
  for (var i = 0; i < 50; i++) {
    if (container.read(authControllerProvider) is! AuthBooting) break;
    await Future<void>.delayed(Duration.zero);
  }
  expect(
    container.read(authControllerProvider),
    signedIn ? isA<SignedIn>() : isA<SignedOut>(),
  );
  return (container: container, prefs: prefs);
}

ProfileController profile(ProviderContainer c) =>
    c.read(profileControllerProvider.notifier);

ProfileEdits edits(ProviderContainer c) => c.read(profileControllerProvider);

Me signedInMe(ProviderContainer c) =>
    (c.read(authControllerProvider) as SignedIn).me;

ThemePreference localTheme(ProviderContainer c) =>
    c.read(preferencesProvider).theme;

const String preferencesPath = '/api/v1/me/preferences';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('theme and language', () {
    test('apply and are saved on the device at once, then sent; the answer '
        'updates the profile', () async {
      final server = ProfileServer(me: meJson());
      final (:container, :prefs) = await boot(server);
      final gate = server.hold();

      final saving = profile(container).setTheme(ThemePreference.light);
      expect(localTheme(container), ThemePreference.light);
      await pumpEventQueue();
      expect(prefs.read().theme, ThemePreference.light);
      expect(server.preferencePatches, [
        {'theme': 'light'},
      ]);
      expect(
        edits(container).pending,
        const PreferencesPatch(theme: ThemePreference.light),
      );
      expect(signedInMe(container).preferences.theme, 'dark');

      gate.complete();
      await saving;
      expect(signedInMe(container).preferences.theme, 'light');
      expect(edits(container).pending, PreferencesPatch.empty);
      expect(edits(container).failure, isNull);
    });

    test('quick changes cost two requests and the last choice wins', () async {
      final server = ProfileServer(me: meJson(theme: 'system'));
      final (:container, prefs: _) = await boot(server);
      final gate = server.hold();

      final first = profile(container).setTheme(ThemePreference.dark);
      await pumpEventQueue();
      unawaited(profile(container).setTheme(ThemePreference.light));
      // Back to the server's value, but a change is on its way: sent too.
      final last = profile(container).setTheme(ThemePreference.system);
      gate.complete();
      await Future.wait([first, last]);

      expect(server.preferencePatches, [
        {'theme': 'dark'},
        {'theme': 'system'},
      ]);
      expect(localTheme(container), ThemePreference.system);
      expect(signedInMe(container).preferences.theme, 'system');
      expect(server.preferences['theme'], 'system');
      expect(edits(container).pending, PreferencesPatch.empty);
    });

    test('choices of different fields made meanwhile go together', () async {
      final server = ProfileServer();
      final (:container, prefs: _) = await boot(server);
      final gate = server.hold();

      final first = profile(container).setTheme(ThemePreference.light);
      await pumpEventQueue();
      unawaited(profile(container).setLocale(AppLocale.enUs));
      final last = profile(container).setCurrency(Currency.usd);
      gate.complete();
      await Future.wait([first, last]);

      expect(server.preferencePatches, [
        {'theme': 'light'},
        {'locale': 'en-US', 'currency': 'USD'},
      ]);
      expect(container.read(appLocaleProvider), AppLocale.enUs);
      expect(signedInMe(container).preferences.currency, 'USD');
    });

    test('a refusal puts the profile value back on the device and reports '
        'it', () async {
      final server = ProfileServer(me: meJson())
        ..fail(preferencesPath, Reply.problem(503, 'unavailable'));
      final (:container, :prefs) = await boot(server);

      await profile(container).setTheme(ThemePreference.light);

      expect(localTheme(container), ThemePreference.dark);
      expect(prefs.read().theme, ThemePreference.dark);
      expect(edits(container).pending, PreferencesPatch.empty);
      final failure = edits(container).failure;
      expect(failure, isNotNull);
      expect((failure!.error as ApiProblemException).status, 503);
      // The revert itself sends nothing.
      expect(server.preferencePatches, hasLength(1));

      // A language refused the same way goes back too.
      server.fail(preferencesPath, Reply.unreachable);
      await profile(container).setLocale(AppLocale.esEs);
      expect(container.read(appLocaleProvider), AppLocale.ptBr);
      expect(edits(container).failure, isNot(same(failure)));
      expect(edits(container).failure!.error, isA<NetworkException>());
    });

    test('a refusal keeps a newer choice queued meanwhile', () async {
      final server = ProfileServer(me: meJson())
        ..fail(preferencesPath, Reply.problem(503, 'unavailable'));
      final (:container, prefs: _) = await boot(server);
      final gate = server.hold();

      final first = profile(container).setTheme(ThemePreference.light);
      await pumpEventQueue();
      final last = profile(container).setTheme(ThemePreference.system);
      gate.complete();
      await Future.wait([first, last]);

      expect(server.preferencePatches, [
        {'theme': 'light'},
        {'theme': 'system'},
      ]);
      expect(localTheme(container), ThemePreference.system);
      expect(signedInMe(container).preferences.theme, 'system');
      expect(edits(container).failure, isNotNull);
    });

    test('a refusal leaves alone a value the device moved on from', () async {
      final server = ProfileServer(me: meJson())
        ..fail(preferencesPath, Reply.problem(503, 'unavailable'));
      final (:container, prefs: _) = await boot(server);
      final gate = server.hold();

      final saving = profile(container).setTheme(ThemePreference.light);
      await pumpEventQueue();
      // Changed without the controller (no request): not undone.
      await container
          .read(preferencesProvider.notifier)
          .setTheme(ThemePreference.system);
      gate.complete();
      await saving;
      expect(localTheme(container), ThemePreference.system);
    });

    test('a value the profile already has sends nothing', () async {
      final server = ProfileServer(me: meJson(locale: 'es-ES'));
      final (:container, prefs: _) = await boot(server);

      await profile(container).setTheme(ThemePreference.dark);
      await profile(container).setLocale(AppLocale.esEs);
      await profile(container).setCurrency(Currency.brl);
      await profile(container).setBudgetAlerts(enabled: true);

      expect(server.preferencePatches, isEmpty);
      expect(edits(container).pending, PreferencesPatch.empty);
    });

    test('signed out, a change stays on the device', () async {
      final server = ProfileServer();
      final (:container, :prefs) = await boot(server, signedIn: false);

      await profile(container).setTheme(ThemePreference.dark);
      await profile(container).setLocale(AppLocale.enUs);
      await profile(container).setCurrency(Currency.usd);

      expect(localTheme(container), ThemePreference.dark);
      expect(prefs.read().locale, AppLocale.enUs);
      expect(server.adapter.sent, isEmpty);
      expect(edits(container).pending, PreferencesPatch.empty);
    });

    test('start-up and sign-in apply the profile without sending it '
        'back', () async {
      const local = AppPreferences(
        locale: AppLocale.enUs,
        theme: ThemePreference.light,
      );
      final server = ProfileServer(me: meJson());
      final (:container, prefs: _) = await boot(server, local: local);
      expect(localTheme(container), ThemePreference.dark);
      expect(container.read(appLocaleProvider), AppLocale.ptBr);
      expect(server.adapter.paths, ['GET /api/v1/me']);

      final signedOut = await boot(server, signedIn: false, local: local);
      server.adapter.sent.clear();
      await signedOut.container
          .read(authControllerProvider.notifier)
          .signIn(email: 'ana@example.com', password: 'a-long-password');
      await pumpEventQueue();
      expect(signedOut.container.read(authControllerProvider), isA<SignedIn>());
      expect(localTheme(signedOut.container), ThemePreference.dark);
      expect(server.adapter.paths, [
        'POST /api/v1/auth/login',
        'GET /api/v1/me',
      ]);
    });
  });

  group('currency and budget alerts', () {
    test('show as pending until the answer', () async {
      final server = ProfileServer();
      final (:container, prefs: _) = await boot(server);
      final gate = server.hold();

      final saving = profile(container).setBudgetAlerts(enabled: false);
      expect(
        edits(container).pending,
        const PreferencesPatch(budgetAlerts: false),
      );
      gate.complete();
      await saving;

      expect(server.preferencePatches, [
        {'budgetAlerts': false},
      ]);
      expect(signedInMe(container).preferences.budgetAlerts, isFalse);
      expect(edits(container).pending, PreferencesPatch.empty);
    });

    test('a refusal drops the pending value: the profile shows '
        'again', () async {
      final server = ProfileServer()
        ..fail(
          preferencesPath,
          Reply.problem(
            422,
            'validation_failed',
            errors: [
              {'field': 'currency', 'code': 'invalid'},
            ],
          ),
        );
      final (:container, prefs: _) = await boot(server);

      await profile(container).setCurrency(Currency.eur);

      expect(edits(container).pending, PreferencesPatch.empty);
      expect(signedInMe(container).preferences.currency, 'BRL');
      expect(edits(container).failure, isNotNull);
    });
  });

  group('the queue', () {
    test('a choice made while the last answer settles is still sent', () async {
      final server = ProfileServer();
      final (:container, prefs: _) = await boot(server);
      var fired = false;
      // Runs inside the loop's last step, when the first answer settles.
      container.listen(profileControllerProvider, (_, next) {
        if (!fired && next.pending.isEmpty) {
          fired = true;
          unawaited(profile(container).setBudgetAlerts(enabled: false));
        }
      });

      await profile(container).setCurrency(Currency.usd);
      await pumpEventQueue();

      expect(server.preferencePatches, [
        {'currency': 'USD'},
        {'budgetAlerts': false},
      ]);
      expect(signedInMe(container).preferences.budgetAlerts, isFalse);

      // And a later one starts a new loop.
      await profile(container).setTheme(ThemePreference.light);
      expect(server.preferencePatches, hasLength(3));
    });

    test('an answer after sign-out changes nothing', () async {
      final server = ProfileServer(me: meJson())
        ..fail(preferencesPath, Reply.problem(503, 'unavailable'));
      final (:container, prefs: _) = await boot(server);
      final gate = server.hold();

      final saving = profile(container).setTheme(ThemePreference.light);
      await pumpEventQueue();
      await container.read(authControllerProvider.notifier).signOut();
      gate.complete();
      await saving;

      expect(container.read(authControllerProvider), isA<SignedOut>());
      // Not put back, not reported: that session is over.
      expect(localTheme(container), ThemePreference.light);
      expect(edits(container), const ProfileEdits());
    });

    test('an answer for an earlier person never reaches the next', () async {
      final server = ProfileServer(me: meJson());
      final (:container, prefs: _) = await boot(server);
      final gate = server.hold();

      final saving = profile(container).setCurrency(Currency.usd);
      await pumpEventQueue();
      await container.read(authControllerProvider.notifier).signOut();
      server.me = meJson(id: 'u2', name: 'Bia');
      await container
          .read(authControllerProvider.notifier)
          .signIn(email: 'bia@example.com', password: 'a-long-password');
      await pumpEventQueue();
      expect(signedInMe(container).id, 'u2');

      gate.complete();
      await saving;
      await pumpEventQueue();
      expect(signedInMe(container).id, 'u2');
      expect(edits(container).pending, PreferencesPatch.empty);

      // The next person's choices go out on their own loop.
      await profile(container).setBudgetAlerts(enabled: false);
      expect(server.preferencePatches.last, {'budgetAlerts': false});
      expect(signedInMe(container).preferences.budgetAlerts, isFalse);
    });
  });

  group('rename', () {
    test('sends the trimmed name and changes only the name', () async {
      final server = ProfileServer();
      final (:container, prefs: _) = await boot(server);
      final before = signedInMe(container);

      await profile(container).rename('  Bia Souza ');

      expect(server.adapter.sent.last.data, {'name': 'Bia Souza'});
      expect(signedInMe(container), before.copyWith(name: 'Bia Souza'));
    });

    test('a refusal throws, with the field codes', () async {
      final server = ProfileServer();
      final (:container, prefs: _) = await boot(server);
      // After the start-up `GET /me`, which shares the path.
      server.fail(
        '/api/v1/me',
        Reply.problem(
          422,
          'validation_failed',
          errors: [
            {'field': 'name', 'code': 'too_long'},
          ],
        ),
      );

      await expectLater(
        profile(container).rename('x' * 101),
        throwsA(
          isA<ApiProblemException>().having(
            (e) => e.problem.errors.single.knownCode,
            'code',
            FieldCode.tooLong,
          ),
        ),
      );
      expect(signedInMe(container).name, 'Ana');
    });
  });
}
