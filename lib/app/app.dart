import 'package:flutter/widgets.dart';
import 'package:monthra/core/config/env.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// The root widget. The brand theme, routes and localizations arrive with
/// the design system, i18n and auth pull requests.
class MonthraApp extends StatelessWidget {
  const new({required this.env, super.key});

  final Env env;

  @override
  Widget build(BuildContext context) {
    return ShadApp(
      title: 'Monthra',
      theme: ShadThemeData(
        brightness: Brightness.light,
        colorScheme: const ShadZincColorScheme.light(),
      ),
      darkTheme: ShadThemeData(
        brightness: Brightness.dark,
        colorScheme: const ShadZincColorScheme.dark(),
      ),
      home: PlaceholderPage(env: env),
    );
  }
}

/// Shown until the first real screens land.
class PlaceholderPage extends StatelessWidget {
  const new({required this.env, super.key});

  final Env env;

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
            const SizedBox(height: 24),
            Text('Monthra', style: theme.textTheme.h2),
            if (!env.isProduction) ...[
              const SizedBox(height: 12),
              ShadBadge.secondary(child: Text(env.appEnv.name)),
            ],
          ],
        ),
      ),
    );
  }
}
