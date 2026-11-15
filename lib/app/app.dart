import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monthra/core/config/env.dart';
import 'package:monthra/core/design_system/catalog/design_system_catalog.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/core/platform/boot_hint.dart' as boot_hint;
import 'package:monthra/features/settings/preferences/application/preferences_providers.dart';
import 'package:monthra/features/settings/preferences/domain/app_locale.dart';
import 'package:monthra/features/settings/preferences/domain/theme_preference.dart';
import 'package:monthra/features/settings/preferences/presentation/language_picker.dart';
import 'package:monthra/features/settings/preferences/presentation/theme_preference_picker.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// A production build (`APP_ENV`): the catalog branch compiles away there.
const bool _productionBuild = String.fromEnvironment('APP_ENV') == 'production';

/// Saves the web boot hint (`boot_hint.dart`); tests pass a recorder.
typedef BootHintSaver = void Function({
  required String languageTag,
  String? theme,
});

/// The root widget: applies the theme and language of [preferencesProvider]
/// and [appLocaleProvider]. Routes arrive with the auth pull request; until
/// then the home is the design system catalog outside production and the
/// brand page in production.
class MonthraApp extends ConsumerStatefulWidget {
  const new({
    required this.env,
    this.saveBootHint = boot_hint.saveBootHint,
    super.key,
  });

  final Env env;
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
    final env = widget.env;
    final showCatalog = !_productionBuild && !env.isProduction;
    final theme = ref.watch(preferencesProvider.select((p) => p.theme));
    final locale = ref.watch(appLocaleProvider);
    return ShadApp(
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
      home: showCatalog
          ? DesignSystemCatalog(
              env: env,
              actions: const [ThemePreferencePicker(), LanguagePicker()],
            )
          : const PlaceholderPage(),
    );
  }
}

/// The production home until the first real screens land.
class PlaceholderPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final symbol = theme.brightness == Brightness.dark
        ? 'assets/brand/monthra-simbolo-branco.svg'
        : 'assets/brand/monthra-simbolo.svg';
    return ColoredBox(
      color: theme.colorScheme.background,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(symbol, width: 96, height: 96),
            const SizedBox(height: MonthraSpacing.x6),
            Text(
              'Monthra',
              style: theme.textTheme.h2.copyWith(
                color: theme.colorScheme.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
