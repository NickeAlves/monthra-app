import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:monthra/app/router.dart';
import 'package:monthra/core/config/env_provider.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/core/network/api_error_text.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/features/auth/application/auth_controller.dart';
import 'package:monthra/features/auth/application/auth_state.dart';
import 'package:monthra/features/auth/presentation/widgets/form_alert.dart';
import 'package:monthra/features/settings/preferences/presentation/language_picker.dart';
import 'package:monthra/features/settings/preferences/presentation/theme_preference_picker.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// The signed-in start page until the app shell lands (shell-settings PR):
/// a greeting, the pickers and the way out.
class HomePage extends ConsumerStatefulWidget {
  const new({super.key});

  static const double maxWidth = 560;

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _busy = false;
  ApiException? _error;

  Future<void> _signOut() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).signOut();
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final l10n = context.l10n;
    final auth = ref.watch(authControllerProvider);
    final name = auth is SignedIn ? auth.me.name : '';
    final catalog = !productionBuild && !ref.watch(envProvider).isProduction;
    final error = _error;
    return ColoredBox(
      color: theme.colorScheme.background,
      child: DefaultTextStyle(
        style: theme.textTheme.p.copyWith(color: theme.colorScheme.foreground),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(MonthraSpacing.x6),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: HomePage.maxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        l10n.homeGreeting(name),
                        style: theme.textTheme.h2.copyWith(
                          color: theme.colorScheme.foreground,
                        ),
                      ),
                    ),
                    const SizedBox(height: MonthraSpacing.x2),
                    Text(
                      l10n.homeComingSoon,
                      style: theme.textTheme.p.copyWith(
                        color: theme.colorScheme.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: MonthraSpacing.x8),
                    const Wrap(
                      spacing: MonthraSpacing.x2,
                      runSpacing: MonthraSpacing.x2,
                      children: [ThemePreferencePicker(), LanguagePicker()],
                    ),
                    const SizedBox(height: MonthraSpacing.x8),
                    if (error != null) ...[
                      FormAlert.error(l10n.apiError(error)),
                      const SizedBox(height: MonthraSpacing.x4),
                    ],
                    Wrap(
                      spacing: MonthraSpacing.x2,
                      runSpacing: MonthraSpacing.x2,
                      children: [
                        ShadButton.outline(
                          enabled: !_busy,
                          onPressed: _signOut,
                          leading: const Icon(LucideIcons.logOut),
                          child: ButtonLabel(l10n.homeSignOut),
                        ),
                        if (catalog)
                          ShadButton.ghost(
                            onPressed: () =>
                                context.push(AppRoutes.designSystem),
                            leading: const Icon(LucideIcons.palette),
                            child: ButtonLabel(l10n.homeDesignSystem),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
