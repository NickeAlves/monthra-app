import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:monthra/app/routes.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/core/network/api_problem.dart';
import 'package:monthra/features/auth/application/auth_controller.dart';
import 'package:monthra/features/auth/application/auth_state.dart';
import 'package:monthra/features/settings/data/me_api.dart';
import 'package:monthra/features/settings/presentation/data/widgets/data_point.dart';
import 'package:monthra/features/settings/presentation/security/mfa_profile.dart';
import 'package:monthra/features/settings/presentation/security/widgets/step_up_form.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Deletes the account and its data (`DELETE /me`, LGPD): what it erases,
/// a way to export first, then the password and, with two-step
/// verification on, a code. A dialog asks once more before anything is
/// sent (user decision of 2026-11-22: no word to type). Once deleted, the
/// session here ends too and the sign-in page says so.
class DeleteAccountPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final l10n = context.l10n;
    final email = ref.watch(
      authControllerProvider.select((s) => s is SignedIn ? s.me.email : null),
    );
    void back() => context.go(AppRoutes.settings);

    Future<void> delete(String password, String code) async {
      final confirmed = await showMonthraConfirm(
        context,
        title: l10n.deleteAccountDialogTitle,
        description: l10n.deleteAccountDialogDescription,
        confirmLabel: l10n.deleteAccountDialogConfirm,
        cancelLabel: l10n.appCancel,
        barrierLabel: l10n.appClose,
        destructive: true,
      );
      if (!confirmed || !context.mounted) return;
      final auth = ref.read(authControllerProvider.notifier);
      try {
        await ref
            .read(meApiProvider)
            .deleteAccount(password: password, code: code);
      } on ApiProblemException catch (e) {
        // No code sent, yet one was asked: two-step verification was turned
        // on elsewhere. Once the profile says so, the form asks for it.
        if (code.isEmpty && e.code == ProblemCode.mfaCodeInvalid) {
          await reloadMfa(ref);
        }
        rethrow;
      }
      // The server already ended every session (and a browser's cookies);
      // the guard then goes to the sign-in page, without `from`.
      await auth.sessionEnded(AuthNotice.accountDeleted);
    }

    const between = SizedBox(height: MonthraSpacing.x4);
    final destructive = theme.colorScheme.destructive;
    return MonthraPage(
      title: l10n.deleteAccountTitle,
      description: l10n.deleteAccountDescription,
      back: MonthraPageBack(label: l10n.navSettings, onPressed: back),
      maxWidth: MonthraLayout.maxFormWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MonthraCard(
            title: Text(l10n.deleteAccountWhatTitle),
            // ShadCard sets the content right under the title.
            child: Padding(
              padding: const EdgeInsets.only(top: MonthraSpacing.x4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DataPoint(
                    icon: LucideIcons.trash2300,
                    text: l10n.deleteAccountErased,
                  ),
                  between,
                  DataPoint(
                    icon: LucideIcons.logOut300,
                    text: l10n.deleteAccountSignedOut,
                  ),
                  between,
                  DataPoint(
                    icon: LucideIcons.shieldCheck300,
                    text: l10n.deleteAccountKept,
                  ),
                  if (email != null) ...[
                    between,
                    DataPoint(
                      icon: LucideIcons.mail300,
                      text: l10n.deleteAccountEmail(email),
                    ),
                  ],
                  between,
                  DataPoint(
                    icon: LucideIcons.triangleAlert300,
                    color: destructive,
                    text: l10n.deleteAccountFinal,
                  ),
                  const SizedBox(height: MonthraSpacing.x6),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: MonthraTapTarget(
                      child: ShadButton.outline(
                        onPressed: () => context.go(AppRoutes.settingsExport),
                        leading: const Icon(LucideIcons.download300),
                        child: ButtonLabel(l10n.deleteAccountExportFirst),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: MonthraSpacing.x6),
          MonthraCard(
            title: Text(l10n.deleteAccountConfirmTitle),
            child: Padding(
              padding: const EdgeInsets.only(top: MonthraSpacing.x6),
              child: StepUpForm(
                askCode: watchMfaEnabled(ref),
                submitLabel: l10n.deleteAccountSubmit,
                destructive: true,
                onSubmit: delete,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
