import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/core/forms/currency_select.dart';
import 'package:monthra/features/auth/application/auth_controller.dart';
import 'package:monthra/features/auth/application/auth_state.dart';
import 'package:monthra/features/auth/data/models/me.dart';
import 'package:monthra/features/settings/application/profile_controller.dart';
import 'package:monthra/features/settings/preferences/presentation/language_picker.dart';
import 'package:monthra/features/settings/preferences/presentation/theme_preference_picker.dart';
import 'package:monthra/features/settings/presentation/widgets/settings_row.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Language, theme, default currency and budget alert emails, saved to the
/// profile as they change ([ProfileController]).
class PreferencesSection extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final preferences = ref.watch(
      authControllerProvider.select(
        (s) => s is SignedIn ? s.me.preferences : null,
      ),
    );
    // Only while signing out, for a frame.
    if (preferences == null) return const SizedBox.shrink();
    final pending = ref.watch(
      profileControllerProvider.select((e) => e.pending),
    );
    final profile = ref.read(profileControllerProvider.notifier);
    final budgetAlerts = pending.budgetAlerts ?? preferences.budgetAlerts;
    const gap = SizedBox(height: MonthraSpacing.x6);
    return MonthraCard(
      title: Text(l10n.settingsPreferencesTitle),
      description: Text(l10n.settingsPreferencesDescription),
      // ShadCard sets the content right under the description.
      child: Padding(
        padding: const EdgeInsets.only(top: MonthraSpacing.x6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SettingsRow(
              title: l10n.preferencesLanguage,
              description: l10n.settingsLanguageDescription,
              controlLabeled: true,
              control: const LanguagePicker(),
            ),
            gap,
            SettingsRow(
              title: l10n.preferencesTheme,
              description: l10n.settingsThemeDescription,
              controlLabeled: true,
              control: const ThemePreferencePicker(),
            ),
            gap,
            SettingsRow(
              title: l10n.settingsCurrencyLabel,
              description: l10n.settingsCurrencyDescription,
              controlLabeled: true,
              control: CurrencySelect(
                value: pending.currency ?? preferences.currencyValue,
                label: l10n.settingsCurrencyLabel,
                onChanged: (currency) =>
                    unawaited(profile.setCurrency(currency)),
              ),
            ),
            gap,
            ShadSwitch(
              value: budgetAlerts,
              onChanged: (enabled) =>
                  unawaited(profile.setBudgetAlerts(enabled: enabled)),
              label: Text(l10n.settingsBudgetAlertsLabel),
              sublabel: Text(l10n.settingsBudgetAlertsDescription),
            ),
          ],
        ),
      ),
    );
  }
}
