import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/features/settings/application/profile_controller.dart';
import 'package:monthra/features/settings/preferences/application/preferences_providers.dart';
import 'package:monthra/features/settings/preferences/domain/theme_preference.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Picks System, Light or Dark (§7.6), applied at once (the theme animates
/// over 200 ms) and, signed in, saved to the profile ([ProfileController]).
/// System follows the device live.
class ThemePreferencePicker extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final current = ref.watch(preferencesProvider.select((p) => p.theme));
    Widget option(ThemePreference value, IconData icon, String label) {
      final selected = value == current;
      void select() => unawaited(
        ref.read(profileControllerProvider.notifier).setTheme(value),
      );
      final leading = Icon(icon);
      final child = ButtonLabel(label);
      // One node per option: shadcn splits a button's flags, label and tap
      // across nodes, and the selected state would sit apart from them.
      return MonthraTapTarget(
        child: Semantics(
          selected: selected,
          inMutuallyExclusiveGroup: true,
          child: selected
              ? ShadButton.secondary(
                  onPressed: select,
                  leading: leading,
                  child: child,
                )
              : ShadButton.ghost(
                  onPressed: select,
                  leading: leading,
                  child: child,
                ),
        ),
      );
    }

    return Semantics(
      container: true,
      label: l10n.preferencesTheme,
      child: Wrap(
        children: [
          option(
            ThemePreference.system,
            LucideIcons.monitor300,
            l10n.themeSystem,
          ),
          option(ThemePreference.light, LucideIcons.sun300, l10n.themeLight),
          option(ThemePreference.dark, LucideIcons.moon300, l10n.themeDark),
        ],
      ),
    );
  }
}
