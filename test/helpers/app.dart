import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/app/app.dart';
import 'package:monthra/app/not_found_page.dart';
import 'package:monthra/app/overrides.dart';
import 'package:monthra/app/router.dart';
import 'package:monthra/core/config/env.dart';
import 'package:monthra/core/design_system/catalog/design_system_catalog.dart';
import 'package:monthra/core/network/api_providers.dart';
import 'package:monthra/core/network/session_refresher.dart';
import 'package:monthra/core/security/token_store.dart';
import 'package:monthra/features/auth/application/auth_controller.dart';
import 'package:monthra/features/auth/captcha/captcha_view.dart';
import 'package:monthra/features/auth/data/session_hint.dart';
import 'package:monthra/features/auth/presentation/auth_layout.dart';
import 'package:monthra/features/home/presentation/home_page.dart';
import 'package:monthra/features/settings/preferences/application/preferences_providers.dart';
import 'package:monthra/features/settings/preferences/data/preferences_store.dart';

import 'captcha.dart';
import 'fake_api.dart';
import 'frame.dart';

/// A boot hint the app saved (see `PumpMonthraApp.pumpMonthraApp`).
typedef SavedBootHint = ({String languageTag, String? theme});

final Env localEnv = Env(
  appEnv: AppEnv.local,
  apiBaseUrl: Uri.parse('http://localhost:8080'),
);

/// An API that knows nothing: any call it gets is a `404`.
FakeAdapter silentApi() => FakeAdapter((_) => Reply.problem(404, 'not_found'));

extension PumpMonthraApp on WidgetTester {
  /// Pumps the whole app as `main` does, with [store] in place of the
  /// device's preferences and [api] answering its calls, opened at
  /// [location] (the platform's initial route, as a browser address or a
  /// deep link gives it). The session travels as [mode] says, from [tokens]
  /// on a device and [hint] on the web; the web boot hints it saves go to
  /// [bootHints]. The captcha page is [captcha] (a [FakeCaptcha] that never
  /// posts by default); it only shows with an [env] like [captchaEnv].
  Future<void> pumpMonthraApp({
    Env? env,
    PreferencesStore? store,
    List<SavedBootHint>? bootHints,
    FakeAdapter? api,
    SessionMode mode = SessionMode.bearer,
    TokenStore? tokens,
    SessionHint? hint,
    String? location,
    FakeCaptcha? captcha,
  }) async {
    if (location != null) {
      platformDispatcher.defaultRouteNameTestValue = location;
      addTearDown(platformDispatcher.clearDefaultRouteNameTestValue);
    }
    await pumpWidget(
      ProviderScope(
        overrides: [
          ...appOverrides(
            env: env ?? localEnv,
            preferences: store ?? MemoryPreferencesStore(),
          ),
          httpAdapterProvider.overrideWithValue(api ?? silentApi()),
          sessionModeProvider.overrideWithValue(mode),
          tokenStoreProvider.overrideWithValue(tokens ?? MemoryTokenStore()),
          sessionHintProvider.overrideWithValue(hint ?? MemorySessionHint()),
          captchaViewBuilderProvider.overrideWithValue(
            (captcha ?? FakeCaptcha()).builder,
          ),
        ],
        child: MonthraApp(
          saveBootHint: ({required languageTag, theme}) =>
              bootHints?.add((languageTag: languageTag, theme: theme)),
        ),
      ),
    );
    await pumpUntilLocalized(appPage, appContainer.read(appLocaleProvider));
  }

  /// Whatever the app shows now: a page of the router, or the boot screens.
  Finder get appPage => find.byWidgetPredicate(
    (w) =>
        w is AuthLayout ||
        w is HomePage ||
        w is NotFoundPage ||
        w is DesignSystemCatalog ||
        w is BootScreen ||
        w is BootUnavailable,
  );

  /// The app's provider container.
  ProviderContainer get appContainer =>
      ProviderScope.containerOf(element(find.byType(MonthraApp)));

  /// The address the router shows now (path, query and fragment).
  Uri get appLocation =>
      appContainer.read(routerProvider).routerDelegate.currentConfiguration.uri;

  /// Pumps zero-length frames until [finder] shows (async work in between),
  /// a few at most.
  Future<void> pumpUntilFound(Finder finder, {int frames = 20}) async {
    for (var i = 0; i < frames && finder.evaluate().isEmpty; i++) {
      await pump(Duration.zero);
    }
    expect(finder, findsWidgets);
  }
}
