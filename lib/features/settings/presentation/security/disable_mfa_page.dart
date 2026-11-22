import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:monthra/app/routes.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/core/network/api_problem.dart';
import 'package:monthra/features/auth/data/models/me.dart';
import 'package:monthra/features/settings/data/mfa_api.dart';
import 'package:monthra/features/settings/presentation/security/mfa_profile.dart';
import 'package:monthra/features/settings/presentation/security/widgets/step_up_form.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Turns two-step verification off (`POST /auth/mfa/disable`) with the
/// password and a code from the app or a recovery code.
class DisableMfaPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final enabled = watchMfaEnabled(ref);
    void back() => context.go(AppRoutes.settings);

    Future<void> disable(String password, String code) async {
      try {
        await ref.read(mfaApiProvider).disable(password: password, code: code);
      } on ApiProblemException catch (e) {
        if (e.code != ProblemCode.mfaNotEnabled) rethrow;
        // Turned off elsewhere: the page says so.
        await reloadMfa(ref);
        return;
      }
      if (!context.mounted) return;
      applyMfa(ref, const MfaStatus(enabled: false, recoveryCodesRemaining: 0));
      showMonthraToast(
        context,
        title: l10n.mfaDisabledToast,
        closeLabel: l10n.appClose,
      );
      back();
    }

    return MonthraPage(
      title: l10n.mfaDisableTitle,
      description: l10n.mfaDisableDescription,
      back: MonthraPageBack(label: l10n.navSettings, onPressed: back),
      maxWidth: MonthraLayout.maxFormWidth,
      child: MonthraCard(
        child: enabled
            ? StepUpForm(
                submitLabel: l10n.mfaDisableSubmit,
                destructive: true,
                onSubmit: disable,
              )
            : EmptyState(
                icon: LucideIcons.shieldOff,
                title: l10n.mfaAlreadyOff,
                action: ShadButton.outline(
                  onPressed: back,
                  child: ButtonLabel(l10n.navSettings),
                ),
              ),
      ),
    );
  }
}
