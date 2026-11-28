import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monthra/core/config/env_provider.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/core/forms/form_alert.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/core/network/api_problem.dart';
import 'package:monthra/features/auth/captcha/captcha_gate.dart';
import 'package:monthra/features/auth/captcha/captcha_request.dart';
import 'package:monthra/features/auth/captcha/captcha_view.dart';
import 'package:monthra/features/settings/preferences/application/preferences_providers.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// The security check of a form, shown once the server asked for it
/// ([CaptchaGate.needed]). [onResend] sends the form again when the check
/// the last attempt was refused for passes.
class CaptchaField extends ConsumerWidget {
  const new({
    required this.gate,
    required this.action,
    required this.onResend,
    super.key,
  });

  final CaptchaGate gate;
  final CaptchaAction action;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ListenableBuilder(
    listenable: gate,
    builder: (context, _) {
      if (!gate.needed) return const SizedBox.shrink();
      final l10n = context.l10n;
      final theme = ShadTheme.of(context);
      final body = switch (gate.status) {
        CaptchaStatus.unsupported => FormAlert(
          message: l10n.authCaptchaUnsupported,
          destructive: true,
          icon: LucideIcons.circleAlert,
        ),
        CaptchaStatus.failed => FormAlert(
          message: l10n.authCaptchaFailed,
          destructive: true,
          icon: LucideIcons.circleAlert,
          action: MonthraTapTarget(
            child: ShadButton.outline(
              onPressed: gate.retry,
              leading: const Icon(LucideIcons.rotateCw),
              child: ButtonLabel(l10n.appRetry),
            ),
          ),
        ),
        _ => _widget(context, ref),
      };
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.authCaptchaLabel, style: theme.textTheme.small),
          const SizedBox(height: MonthraSpacing.x2),
          body,
          if (gate.waitingForToken &&
              (gate.status == CaptchaStatus.loading ||
                  gate.status == CaptchaStatus.ready)) ...[
            const SizedBox(height: MonthraSpacing.x2),
            Text(l10n.authCaptchaHint, style: theme.textTheme.muted),
          ],
        ],
      );
    },
  );

  Widget _widget(BuildContext context, WidgetRef ref) {
    final env = ref.watch(envProvider);
    final page = env.captchaPage;
    final siteKey = env.turnstileSiteKey;
    if (page == null || siteKey == null) return const SizedBox.shrink();
    final theme = ShadTheme.of(context);
    final languageTag = ref.watch(appLocaleProvider).tag;
    final build = ref.watch(captchaViewBuilderProvider);
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = CaptchaSize.forWidth(constraints.maxWidth);
        final request = CaptchaRequest(
          page: page,
          siteKey: siteKey,
          action: action,
          brightness: theme.brightness,
          languageTag: languageTag,
          size: size,
          background: theme.colorScheme.background,
        );
        return SizedBox(
          height: size.height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              KeyedSubtree(
                // A new attempt (or new settings) loads the page again.
                key: ValueKey((gate.attempt, request)),
                child: build(
                  request,
                  onMessage: (message) {
                    if (gate.onMessage(message)) onResend();
                  },
                  title: context.l10n.authCaptchaLabel,
                ),
              ),
              if (gate.status == CaptchaStatus.loading)
                Skeleton(height: size.height, radius: MonthraRadii.mdAll),
            ],
          ),
        );
      },
    );
  }
}

/// The alert above a form refused for a captcha this build can show:
/// "complete the check below", or "the check was not accepted". Null for
/// any other error (and without a widget to show), which reads as usual.
Widget? captchaAlert(
  AppLocalizations l10n,
  CaptchaGate gate,
  ApiException? error,
) {
  if (!gate.needed ||
      error is! ApiProblemException ||
      !isCaptchaProblem(error.code)) {
    return null;
  }
  return error.code == ProblemCode.captchaInvalid
      ? FormAlert.error((message: l10n.authCaptchaRejected, reference: null))
      : FormAlert(
          message: l10n.authCaptchaPrompt,
          icon: LucideIcons.shieldCheck,
        );
}
