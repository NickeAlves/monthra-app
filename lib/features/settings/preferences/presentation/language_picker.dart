import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/features/settings/application/profile_controller.dart';
import 'package:monthra/features/settings/preferences/application/preferences_providers.dart';
import 'package:monthra/features/settings/preferences/domain/app_locale.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Picks the UI language (§7.6), applied at once and, signed in, saved to
/// the profile ([ProfileController]). Shows the language the app speaks
/// now, chosen or matched from the device; each language is written in
/// itself. For the settings (and the public landing page); the sign-in
/// pages show none (user decision of 2026-11-15).
class LanguagePicker extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<LanguagePicker> createState() => _LanguagePickerState();
}

class _LanguagePickerState extends ConsumerState<LanguagePicker> {
  static const double _minWidth = 224;

  late final ShadSelectController<AppLocale> _controller = ShadSelectController(
    initialValue: {ref.read(appLocaleProvider)},
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Follows changes made elsewhere too (the device, a sign-in).
    ref.listen(appLocaleProvider, (_, next) => _controller.value = {next});
    // Read as "Language, English (US), button".
    return Semantics(
      container: true,
      button: true,
      label: context.l10n.preferencesLanguage,
      child: ShadSelect<AppLocale>(
        controller: _controller,
        // The list takes the trigger's width: room for the longest name
        // and the check mark beside it.
        minWidth: _minWidth,
        options: [
          for (final locale in AppLocale.values)
            ShadOption(value: locale, child: Text(locale.nativeName)),
        ],
        selectedOptionBuilder: (context, locale) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.languages, size: 16),
            const SizedBox(width: MonthraSpacing.x2),
            Flexible(
              child: Text(
                locale.nativeName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        onChanged: (locale) {
          // Never throws: a failed save is reported by the controller.
          if (locale != null) {
            unawaited(
              ref.read(profileControllerProvider.notifier).setLocale(locale),
            );
          }
        },
      ),
    );
  }
}
