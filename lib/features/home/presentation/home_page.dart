import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/features/auth/application/auth_controller.dart';
import 'package:monthra/features/auth/application/auth_state.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// The dashboard's place in the shell until the dashboard PR: a greeting.
class HomePage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final l10n = context.l10n;
    final name = ref.watch(
      authControllerProvider.select((s) => s is SignedIn ? s.me.name : ''),
    );
    return MonthraPage(
      title: l10n.homeGreeting(name),
      child: Text(
        l10n.homeComingSoon,
        style: theme.textTheme.p.copyWith(
          color: theme.colorScheme.mutedForeground,
        ),
      ),
    );
  }
}
