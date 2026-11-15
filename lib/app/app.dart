import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/widgets.dart';
import 'package:monthra/core/config/env.dart';
import 'package:monthra/core/design_system/catalog/design_system_catalog.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// A production build (`APP_ENV`): the catalog branch compiles away there.
const bool _productionBuild = String.fromEnvironment('APP_ENV') == 'production';

/// The root widget. Routes and localizations arrive with the i18n and auth
/// pull requests; until then the home is the design system catalog outside
/// production and the brand page in production.
class MonthraApp extends StatefulWidget {
  const new({required this.env, super.key});

  final Env env;

  @override
  State<MonthraApp> createState() => _MonthraAppState();
}

class _MonthraAppState extends State<MonthraApp> {
  // Becomes the preferencesProvider (stored and synced) in the next PR.
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    final env = widget.env;
    final showCatalog = !_productionBuild && !env.isProduction;
    return ShadApp(
      title: 'Monthra',
      themeMode: _themeMode,
      theme: monthraTheme(Brightness.light),
      darkTheme: monthraTheme(Brightness.dark),
      themeCurve: MonthraMotion.curve,
      home: showCatalog
          ? DesignSystemCatalog(
              env: env,
              themeMode: _themeMode,
              onThemeModeChanged: (mode) => setState(() => _themeMode = mode),
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
