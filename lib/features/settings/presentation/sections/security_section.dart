import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:monthra/app/routes.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/features/auth/application/auth_controller.dart';
import 'package:monthra/features/auth/application/auth_state.dart';
import 'package:monthra/features/settings/presentation/widgets/settings_row.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// The password, two-step verification and its recovery codes: each change
/// happens on a page of its own, under Settings.
class SecuritySection extends ConsumerWidget {
  const new({super.key});

  /// From how many codes left the card warns.
  static const int lowRecoveryCodes = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final l10n = context.l10n;
    final mfa = ref.watch(
      authControllerProvider.select((s) => s is SignedIn ? s.me.mfa : null),
    );
    // Only while signing out, for a frame.
    if (mfa == null) return const SizedBox.shrink();
    final left = mfa.recoveryCodesRemaining;
    const gap = SizedBox(height: MonthraSpacing.x6);
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
              control: MonthraTapTarget(
                child: ShadButton.outline(
                  onPressed: () => context.go(AppRoutes.settingsPassword),
                  child: ButtonLabel(l10n.settingsPasswordChange),
                ),
              ),
            ),
            gap,
            SettingsRow(
              title: l10n.settingsMfaLabel,
              badge: mfa.enabled
                  ? ShadBadge(child: Text(l10n.settingsMfaOn))
                  : ShadBadge.secondary(child: Text(l10n.settingsMfaOff)),
              description: mfa.enabled
                  ? l10n.settingsMfaOnDescription
                  : l10n.settingsMfaOffDescription,
              control: mfa.enabled
                  ? MonthraTapTarget(
                      child: ShadButton.outline(
                        onPressed: () =>
                            context.go(AppRoutes.settingsMfaDisable),
                        child: ButtonLabel(l10n.settingsMfaTurnOff),
                      ),
                    )
                  : MonthraTapTarget(
                      child: ShadButton(
                        onPressed: () =>
                            context.go(AppRoutes.settingsMfaEnable),
                        child: ButtonLabel(l10n.settingsMfaTurnOn),
                      ),
                    ),
            ),
            if (mfa.enabled) ...[
              gap,
              SettingsRow(
                title: l10n.settingsRecoveryCodesLabel,
                description: l10n.settingsRecoveryCodesLeft(left),
                control: MonthraTapTarget(
                  child: ShadButton.outline(
                    onPressed: () =>
                        context.go(AppRoutes.settingsRecoveryCodes),
                    child: ButtonLabel(l10n.settingsRecoveryCodesNew),
                  ),
                ),
              ),
              if (left <= lowRecoveryCodes) ...[
                const SizedBox(height: MonthraSpacing.x2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(
                        LucideIcons.triangleAlert,
                        size: 16,
                        color: theme.colorScheme.warning,
                      ),
                    ),
                    const SizedBox(width: MonthraSpacing.x2),
                    Expanded(
                      child: Text(
                        l10n.settingsRecoveryCodesLow,
                        style: theme.textTheme.small.copyWith(
                          color: theme.colorScheme.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
