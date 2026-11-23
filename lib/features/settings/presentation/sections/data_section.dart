import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:monthra/app/routes.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/features/settings/presentation/widgets/settings_row.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// The account's data (LGPD): export a copy, or delete the account. Each
/// happens on a page of its own, under Settings.
class DataSection extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return MonthraCard(
      title: Text(l10n.settingsDataTitle),
      description: Text(l10n.settingsDataDescription),
      // ShadCard sets the content right under the description.
      child: Padding(
        padding: const EdgeInsets.only(top: MonthraSpacing.x6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SettingsRow(
              title: l10n.settingsExportLabel,
              description: l10n.settingsExportDescription,
              control: ShadButton.outline(
                onPressed: () => context.go(AppRoutes.settingsExport),
                child: ButtonLabel(l10n.settingsExportOpen),
              ),
            ),
            const SizedBox(height: MonthraSpacing.x6),
            SettingsRow(
              title: l10n.settingsDeleteLabel,
              description: l10n.settingsDeleteDescription,
              control: ShadButton.destructive(
                onPressed: () => context.go(AppRoutes.settingsDeleteAccount),
                child: ButtonLabel(l10n.settingsDeleteOpen),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
