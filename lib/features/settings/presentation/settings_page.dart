import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/features/settings/presentation/settings_sections.dart';
import 'package:monthra/l10n/l10n.dart';

/// Settings (§7.5): one column of cards ([settingsSections]).
class SettingsPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => MonthraPage(
    title: context.l10n.settingsTitle,
    maxWidth: MonthraLayout.maxFormWidth,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, section) in settingsSections.indexed) ...[
          if (i > 0) const SizedBox(height: MonthraSpacing.x6),
          section,
        ],
      ],
    ),
  );
}
