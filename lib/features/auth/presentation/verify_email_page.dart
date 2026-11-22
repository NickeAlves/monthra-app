import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:monthra/app/router.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/core/forms/countdown.dart';
import 'package:monthra/core/forms/fields.dart';
import 'package:monthra/core/forms/form_alert.dart';
import 'package:monthra/core/network/api_error_text.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/core/network/api_problem.dart';
import 'package:monthra/features/auth/data/auth_api.dart';
import 'package:monthra/features/auth/presentation/auth_layout.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

enum _Step { verifying, verified, linkDead, failed }

/// Opened from the confirmation email (`/verify-email#token=…`): confirms
/// the address at once, a single time. A dead link offers a new one.
class VerifyEmailPage extends ConsumerStatefulWidget {
  const new({required this.token, super.key});

  /// The link's token; null when the link had none.
  final String? token;

  @override
  ConsumerState<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends ConsumerState<VerifyEmailPage> {
  final _form = GlobalKey<ShadFormState>();
  final _email = TextEditingController();
  final _resendWait = Countdown();

  /// Read once: the address bar loses it right after the first frame.
  late final String? _token = widget.token;

  late _Step _step = _token == null ? _Step.linkDead : _Step.verifying;
  ApiException? _error;
  bool _busy = false;
  String? _resentTo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      dropLinkFragment(context);
      unawaited(_verify());
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _resendWait.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final token = _token;
    if (token == null) return;
    setState(() {
      _step = _Step.verifying;
      _error = null;
    });
    try {
      await ref.read(authApiProvider).verifyEmail(token);
      if (mounted) setState(() => _step = _Step.verified);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        final dead =
            e is ApiProblemException && e.code == ProblemCode.tokenInvalid;
        _step = dead ? _Step.linkDead : _Step.failed;
        _error = dead ? null : e;
      });
    }
  }

  Future<void> _resend() async {
    if (_busy) return;
    setState(() => _error = null);
    if (!(_form.currentState?.validate() ?? false)) return;
    final email = _email.text.trim();
    setState(() => _busy = true);
    try {
      await ref.read(authApiProvider).resendVerification(email);
      if (!mounted) return;
      _resendWait.start(resendCooldown);
      setState(() => _resentTo = email);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AuthLayout(
      child: switch (_step) {
        _Step.verifying => AuthHeading(title: l10n.authVerifyingTitle),
        _Step.verified => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthHeading(
              title: l10n.authVerifiedTitle,
              subtitle: l10n.authVerifiedMessage,
            ),
            ShadButton(
              onPressed: () => context.go(AppRoutes.login),
              child: ButtonLabel(l10n.authContinue),
            ),
          ],
        ),
        _Step.failed => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthHeading(title: l10n.authVerifyingTitle),
            if (_error case final error?) ...[
              FormAlert.error(l10n.apiError(error)),
              const SizedBox(height: MonthraSpacing.x6),
            ],
            ShadButton(
              onPressed: _verify,
              leading: const Icon(LucideIcons.rotateCw),
              child: ButtonLabel(l10n.appRetry),
            ),
          ],
        ),
        _Step.linkDead => _resendView(l10n),
      },
    );
  }

  Widget _resendView(AppLocalizations l10n) {
    final error = _error;
    final resentTo = _resentTo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthHeading(
          title: l10n.authLinkInvalidTitle,
          subtitle: l10n.authVerifyLinkInvalidMessage,
        ),
        if (error != null) ...[
          FormAlert.error(l10n.apiError(error)),
          const SizedBox(height: MonthraSpacing.x6),
        ] else if (resentTo != null) ...[
          FormAlert(
            message: l10n.authVerificationSent(resentTo),
            icon: LucideIcons.mailCheck,
          ),
          const SizedBox(height: MonthraSpacing.x6),
        ],
        ShadForm(
          key: _form,
          child: AutofillGroup(
            onDisposeAction: AutofillContextAction.cancel,
            child: EmailField(
              controller: _email,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => unawaited(_resend()),
            ),
          ),
        ),
        const SizedBox(height: MonthraSpacing.x6),
        ValueListenableBuilder(
          valueListenable: _resendWait,
          builder: (context, seconds, _) => ShadButton(
            enabled: !_busy && seconds == 0,
            onPressed: _resend,
            leading: const Icon(LucideIcons.mail),
            child: ButtonLabel(
              seconds > 0
                  ? l10n.authResendIn(seconds)
                  : l10n.authResendVerification,
            ),
          ),
        ),
        const SizedBox(height: MonthraSpacing.x4),
        Center(
          child: ShadButton.link(
            onPressed: () => context.go(AppRoutes.login),
            leading: const Icon(LucideIcons.arrowLeft),
            child: ButtonLabel(l10n.authBackToSignIn),
          ),
        ),
      ],
    );
  }
}
