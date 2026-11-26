import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/app/overrides.dart';
import 'package:monthra/core/dates/clock.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/core/network/api_providers.dart';
import 'package:monthra/core/network/session_refresher.dart';
import 'package:monthra/core/security/token_store.dart';
import 'package:monthra/features/auth/application/auth_controller.dart';
import 'package:monthra/features/auth/application/auth_state.dart';
import 'package:monthra/features/settings/preferences/data/preferences_store.dart';
import 'package:monthra/features/settings/preferences/domain/app_locale.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'env.dart';
import 'fake_api.dart';
import 'finance_fixtures.dart';
import 'stub_auth.dart';

/// [child] on the app background of [brightness], with the Monthra theme
/// and the UI strings of [locale], at the top start corner.
class TestFrame extends StatelessWidget {
  const new({
    required this.child,
    this.brightness = Brightness.light,
    this.locale = AppLocale.ptBr,
    super.key,
  });

  final Brightness brightness;
  final AppLocale locale;
  final Widget child;

  @override
  Widget build(BuildContext context) => ShadApp(
    theme: monthraTheme(Brightness.light),
    darkTheme: monthraTheme(Brightness.dark),
    themeMode: brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
    locale: locale.locale,
    supportedLocales: AppLocale.supportedLocales,
    localizationsDelegates: const [AppLocalizations.delegate],
    home: Builder(
      builder: (context) {
        final theme = ShadTheme.of(context);
        return ColoredBox(
          color: theme.colorScheme.background,
          child: DefaultTextStyle(
            style: theme.textTheme.p.copyWith(
              color: theme.colorScheme.foreground,
            ),
            child: Padding(
              padding: const EdgeInsets.all(MonthraSpacing.x4),
              child: Align(alignment: Alignment.topLeft, child: child),
            ),
          ),
        );
      },
    ),
  );
}

extension PumpFrame on WidgetTester {
  /// Pumps [child] inside a [TestFrame] on a [size] window (pixel ratio 1),
  /// under a [ProviderScope] wired as the app's, whose preferences live in
  /// [store] (empty by default). The session is [auth] from the start (no
  /// start-up check) and [api] answers the calls (a `404` for each by
  /// default), as a device sends them.
  Future<void> pumpFrame(
    Widget child, {
    Brightness brightness = Brightness.light,
    AppLocale locale = AppLocale.ptBr,
    Size size = const Size(800, 600),
    PreferencesStore? store,
    AuthState auth = const SignedOut(),
    FakeAdapter? api,
  }) async {
    view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(view.reset);
    await pumpWidget(
      ProviderScope(
        overrides: [
          ...appOverrides(
            env: localEnv,
            preferences: store ?? MemoryPreferencesStore(),
          ),
          httpAdapterProvider.overrideWithValue(api ?? silentApi()),
          sessionModeProvider.overrideWithValue(SessionMode.bearer),
          tokenStoreProvider.overrideWithValue(MemoryTokenStore()),
          authControllerProvider.overrideWith(() => StubAuthController(auth)),
          clockProvider.overrideWithValue(() => testNow),
        ],
        child: TestFrame(brightness: brightness, locale: locale, child: child),
      ),
    );
    await pumpUntilLocalized(find.byWidget(child), locale);
  }

  /// Pumps until [finder] shows in [locale], a few zero-length frames at
  /// most.
  ///
  /// shadcn_ui loads its strings for every language but English from a
  /// deferred library, so `Localizations` holds the first frame of a pt-BR
  /// or es-ES app (and keeps the previous language on a switch) until that
  /// load completes; the VM's `loadLibrary` always waits for a zero-length
  /// timer, which only a pump with a duration runs. flutter_test_config.dart
  /// preloads the libraries, so one frame is usually enough.
  Future<void> pumpUntilLocalized(Finder finder, AppLocale locale) async {
    bool done() =>
        finder.evaluate().isNotEmpty &&
        Localizations.localeOf(element(finder.first)) == locale.locale;
    for (var i = 0; i < 5 && !done(); i++) {
      await pump(Duration.zero);
    }
    expect(done(), isTrue, reason: 'the ${locale.tag} strings never loaded');
  }

  /// The provider container of the frame [pumpFrame] pumped.
  ProviderContainer get frameContainer =>
      ProviderScope.containerOf(element(find.byType(TestFrame)));

  /// Turns animations off, as the platform's reduce-motion setting does.
  void reduceMotion() {
    platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(platformDispatcher.clearAccessibilityFeaturesTestValue);
  }

  /// The theme in effect at [finder].
  ShadThemeData themeAt(Finder finder) => ShadTheme.of(element(finder));
}
