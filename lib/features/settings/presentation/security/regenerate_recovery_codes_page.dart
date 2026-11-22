import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:monthra/app/routes.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/core/network/api_problem.dart';
import 'package:monthra/features/auth/data/models/me.dart';
import 'package:monthra/features/settings/application/unsaved_recovery_codes.dart';
import 'package:monthra/features/settings/data/mfa_api.dart';
import 'package:monthra/features/settings/presentation/security/mfa_profile.dart';
import 'package:monthra/features/settings/presentation/security/widgets/recovery_codes_view.dart';
import 'package:monthra/features/settings/presentation/security/widgets/step_up_form.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Replaces every recovery code (`POST /auth/mfa/recovery-codes`) after
/// the password and a code, then shows the new ones this once.
class RegenerateRecoveryCodesPage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<RegenerateRecoveryCodesPage> createState() =>
      _RegenerateRecoveryCodesPageState();
}

class _RegenerateRecoveryCodesPageState
    extends ConsumerState<RegenerateRecoveryCodesPage> {
  List<String>? _codes;

  void _back() => context.go(AppRoutes.settings);

  Future<void> _regenerate(String password, String code) async {
    final List<String> codes;
    try {
      codes = await ref
          .read(mfaApiProvider)
          .regenerateRecoveryCodes(password: password, code: code);
    } on ApiProblemException catch (e) {
      if (e.code != ProblemCode.mfaNotEnabled) rethrow;
      await reloadMfa(ref);
      return;
    }
    if (!mounted) return;
    final l10n = context.l10n;
    applyMfa(
      ref,
      MfaStatus(enabled: true, recoveryCodesRemaining: codes.length),
    );
    ref.read(unsavedRecoveryCodesProvider.notifier).shown();
    setState(() => _codes = codes);
    showMonthraToast(
      context,
      title: l10n.recoveryCodesNewToast,
      closeLabel: l10n.appClose,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final enabled = watchMfaEnabled(ref);
    final codes = _codes;
    return MonthraPage(
      title: l10n.settingsRecoveryCodesNew,
      description: codes == null ? l10n.recoveryRegenerateDescription : null,
      back: MonthraPageBack(label: l10n.navSettings, onPressed: _back),
      maxWidth: MonthraLayout.maxFormWidth,
      child: codes != null
          ? RecoveryCodesView(
              codes: codes,
              onDone: () {
                ref.read(unsavedRecoveryCodesProvider.notifier).saved();
                _back();
              },
            )
          : MonthraCard(
              child: enabled
                  ? StepUpForm(
                      submitLabel: l10n.recoveryRegenerateSubmit,
                      onSubmit: _regenerate,
                    )
                  : EmptyState(
                      icon: LucideIcons.shieldOff,
                      title: l10n.mfaAlreadyOff,
                      action: ShadButton.outline(
                        onPressed: _back,
                        child: ButtonLabel(l10n.navSettings),
                      ),
                    ),
            ),
    );
  }
}
