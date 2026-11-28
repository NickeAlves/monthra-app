import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// An address the app does not know.
class NotFoundPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final l10n = context.l10n;
    return ColoredBox(
      color: theme.colorScheme.background,
      child: DefaultTextStyle(
        style: theme.textTheme.p.copyWith(color: theme.colorScheme.foreground),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(MonthraSpacing.x6),
              child: EmptyState(
                icon: LucideIcons.mapPinOff,
                title: l10n.notFoundTitle,
                message: l10n.notFoundMessage,
                action: MonthraTapTarget(
                  child: ShadButton(
                    onPressed: () => context.go('/'),
                    child: ButtonLabel(l10n.notFoundHome),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
