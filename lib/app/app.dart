import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monthra/app/router.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/core/network/api_error_text.dart';
import 'package:monthra/core/platform/boot_hint.dart' as boot_hint;
import 'package:monthra/features/auth/application/auth_controller.dart';
import 'package:monthra/features/auth/application/auth_state.dart';
import 'package:monthra/features/settings/preferences/application/preferences_providers.dart';
import 'package:monthra/features/settings/preferences/domain/app_locale.dart';
import 'package:monthra/features/settings/preferences/domain/theme_preference.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Saves the web boot hint (`boot_hint.dart`); tests pass a recorder.
typedef BootHintSaver = void Function({
  required String languageTag,
  String? theme,
});

/// The root widget: applies the theme and language of [preferencesProvider]
/// and [appLocaleProvider], and routes with [routerProvider]. Until the
/// start-up session check settles ([AuthBooting]) only the boot screen
/// shows: no page is built before its guard can run.
class MonthraApp extends ConsumerStatefulWidget {
  const new({this.saveBootHint = boot_hint.saveBootHint, super.key});

  final BootHintSaver saveBootHint;

  @override
  ConsumerState<MonthraApp> createState() => _MonthraAppState();
}

class _MonthraAppState extends ConsumerState<MonthraApp> {
  @override
  void initState() {
    super.initState();
    // The next web visit opens in today's theme and language (boot.js).
    ref
      ..listenManual(
        appLocaleProvider,
        (_, _) => _saveBootHint(),
        fireImmediately: true,
      )
      ..listenManual(
        preferencesProvider.select((p) => p.theme),
        (_, _) => _saveBootHint(),
      );
  }

  void _saveBootHint() {
    final theme = ref.read(preferencesProvider).theme;
    widget.saveBootHint(
      languageTag: ref.read(appLocaleProvider).tag,
      theme: theme == ThemePreference.system ? null : theme.wire,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(preferencesProvider.select((p) => p.theme));
    final locale = ref.watch(appLocaleProvider);
    final gate = ref.watch(
      authControllerProvider.select(
        (auth) => switch (auth) {
          AuthBooting() => _Gate.booting,
          AuthUnavailable() => _Gate.unavailable,
          _ => _Gate.open,
        },
      ),
    );
    return ShadApp.router(
      routerConfig: ref.watch(routerProvider),
      // The brand name, the same in every language.
      title: 'Monthra',
      themeMode: theme.themeMode,
      theme: monthraTheme(Brightness.light),
      darkTheme: monthraTheme(Brightness.dark),
      themeCurve: MonthraMotion.curve,
      locale: locale.locale,
      supportedLocales: AppLocale.supportedLocales,
      // ShadApp adds the shadcn, Material, Cupertino and Widgets ones.
      localizationsDelegates: const [AppLocalizations.delegate],
      builder: (context, child) => switch (gate) {
        _Gate.booting => const BootScreen(),
        _Gate.unavailable => const BootUnavailable(),
        _Gate.open => child ?? const SizedBox.shrink(),
      },
    );
  }
}

enum _Gate { booting, unavailable, open }

/// The start-up screen while the session check runs: the brand symbol on
/// the theme's background, as the splash screens draw it, so nothing
/// flashes between them.
class BootScreen extends StatelessWidget {
  const new({super.key});

  static const double symbolSize = 96;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final symbol = theme.brightness == Brightness.dark
        ? 'assets/brand/monthra-simbolo-branco.svg'
        : 'assets/brand/monthra-simbolo.svg';
    return ColoredBox(
      color: theme.colorScheme.background,
      child: Center(
        child: Semantics(
          // The brand name, the same in every language.
          label: 'Monthra',
          image: true,
          child: SvgPicture.asset(
            symbol,
            width: symbolSize,
            height: symbolSize,
          ),
        ),
      ),
    );
  }
}

/// The start-up check could not reach the API: say so and offer a retry.
class BootUnavailable extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final l10n = context.l10n;
    final auth = ref.watch(authControllerProvider);
    final error = auth is AuthUnavailable ? l10n.apiError(auth.error) : null;
    return ColoredBox(
      color: theme.colorScheme.background,
      child: DefaultTextStyle(
        style: theme.textTheme.p.copyWith(color: theme.colorScheme.foreground),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(MonthraSpacing.x6),
              child: ErrorState(
                title: l10n.appUnavailableTitle,
                message: error?.message,
                onRetry: ref.read(authControllerProvider.notifier).retry,
                retryLabel: l10n.appRetry,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
