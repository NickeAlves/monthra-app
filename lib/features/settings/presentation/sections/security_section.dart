import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:monthra/app/routes.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/features/settings/presentation/widgets/settings_row.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// The password and two-step verification: each change happens on a page
/// of its own, under Settings.
class SecuritySection extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return MonthraCard(
      title: Text(l10n.settingsSecurityTitle),
      description: Text(l10n.settingsSecurityDescription),
      // ShadCard sets the content right under the description.
      child: Padding(
        padding: const EdgeInsets.only(top: MonthraSpacing.x6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SettingsRow(
              title: l10n.settingsPasswordLabel,
              description: l10n.settingsPasswordDescription,
              control: ShadButton.outline(
                onPressed: () => context.go(AppRoutes.settingsPassword),
                child: ButtonLabel(l10n.settingsPasswordChange),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
