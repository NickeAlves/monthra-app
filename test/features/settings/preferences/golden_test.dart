import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/features/settings/preferences/data/preferences_store.dart';
import 'package:monthra/features/settings/preferences/domain/app_locale.dart';
import 'package:monthra/features/settings/preferences/domain/app_preferences.dart';
import 'package:monthra/features/settings/preferences/domain/theme_preference.dart';
import 'package:monthra/features/settings/preferences/presentation/language_picker.dart';
import 'package:monthra/features/settings/preferences/presentation/theme_preference_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../helpers/golden.dart';

/// The preference pickers in both themes (pt-BR, dark chosen). Rendered and
/// compared on Linux only; see "Golden tests" in the README.
void main() {
  PreferencesStore store() => MemoryPreferencesStore(
    const AppPreferences(locale: AppLocale.ptBr, theme: ThemePreference.dark),
  );

  Widget pickers() => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: MonthraSpacing.x4,
    children: [ThemePreferencePicker(), LanguagePicker()],
  );

  goldenTest(
    'preference_pickers',
    size: const Size(480, 140),
    store: store,
    pickers,
  );

  goldenTest(
    'language_picker_open',
    size: const Size(480, 260),
    store: store,
    pickers,
    setup: (tester) async {
      await tester.tap(find.byType(ShadSelect<AppLocale>));
      await tester.pumpAndSettle();
    },
  );
}
