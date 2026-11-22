import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:monthra/app/routes.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/core/forms/form_alert.dart';
import 'package:monthra/core/forms/second_factor_field.dart';
import 'package:monthra/core/network/api_error_text.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/core/network/api_problem.dart';
import 'package:monthra/features/auth/data/models/me.dart';
import 'package:monthra/features/settings/application/unsaved_recovery_codes.dart';
import 'package:monthra/features/settings/data/authenticator_launcher.dart';
import 'package:monthra/features/settings/data/mfa_api.dart';
import 'package:monthra/features/settings/data/models/mfa_setup.dart';
import 'package:monthra/features/settings/presentation/security/mfa_profile.dart';
import 'package:monthra/features/settings/presentation/security/widgets/mfa_secret_key.dart';
import 'package:monthra/features/settings/presentation/security/widgets/recovery_codes_view.dart';
import 'package:monthra/features/settings/presentation/security/widgets/step_up_form.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

enum _Step { password, scan, codes }

/// Turns two-step verification on, one step at a time:
///
/// 1. the password again (`POST /auth/mfa/setup`);
/// 2. the QR code (or the key, or the authenticator app on this device)
///    and a first code (`POST /auth/mfa/enable`), within the setup's
///    `expiresIn`, after which it starts over;
/// 3. the recovery codes, shown this once.
///
/// The secret and the codes live in this page's state only.
class EnableMfaPage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<EnableMfaPage> createState() => _EnableMfaPageState();
}

class _EnableMfaPageState extends ConsumerState<EnableMfaPage> {
  final _form = GlobalKey<ShadFormState>();
  final _factor = SecondFactorController();

  _Step _step = _Step.password;
  MfaSetup? _setup;
  List<String>? _codes;
  Timer? _expiry;
  bool _expired = false;
  bool _canOpenApp = false;
  bool _busy = false;
  ApiException? _error;

  @override
  void dispose() {
    _expiry?.cancel();
    _factor.dispose();
    super.dispose();
  }

  void _back() => context.go(AppRoutes.settings);

  Future<void> _start(String password, String _) async {
    final MfaSetup setup;
    try {
      setup = await ref.read(mfaApiProvider).setup(password);
    } on ApiProblemException catch (e) {
      if (e.code != ProblemCode.mfaAlreadyEnabled) rethrow;
      await reloadMfa(ref);
      return;
    }
    if (!mounted) return;
    _expiry?.cancel();
    _expiry = Timer(Duration(seconds: setup.expiresIn), _startOver);
    setState(() {
      _step = _Step.scan;
      _setup = setup;
      _expired = false;
      _error = null;
    });
    final launcher = ref.read(authenticatorLauncherProvider);
    final canOpen = await launcher.canOpen(Uri.parse(setup.otpauthUri));
    if (mounted && _setup == setup) setState(() => _canOpenApp = canOpen);
  }

  /// The setup ran out (or the server no longer has it): back to step 1.
  void _startOver() {
    if (!mounted || _step != _Step.scan) return;
    _expiry?.cancel();
    _factor.totp.clear();
    setState(() {
      _step = _Step.password;
      _setup = null;
      _expired = true;
      _error = null;
    });
  }

  Future<void> _openApp() async {
    final setup = _setup;
    if (setup == null) return;
    final l10n = context.l10n;
    final opened = await ref
        .read(authenticatorLauncherProvider)
        .open(Uri.parse(setup.otpauthUri));
    if (!opened && mounted) {
      showMonthraToast(
        context,
        title: l10n.mfaNoAuthenticator,
        closeLabel: l10n.appClose,
      );
    }
  }

  Future<void> _enable() async {
    if (_busy || _setup == null) return;
    setState(() => _error = null);
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _busy = true);
    final l10n = context.l10n;
    try {
      final codes = await ref.read(mfaApiProvider).enable(_factor.code);
      if (!mounted) return;
      _expiry?.cancel();
      applyMfa(
        ref,
        MfaStatus(enabled: true, recoveryCodesRemaining: codes.length),
      );
      ref.read(unsavedRecoveryCodesProvider.notifier).shown();
      setState(() {
        _step = _Step.codes;
        _codes = codes;
        _setup = null;
      });
      showMonthraToast(
        context,
        title: l10n.mfaEnabledToast,
        closeLabel: l10n.appClose,
      );
    } on ApiProblemException catch (e) {
      if (!mounted) return;
      switch (e.code) {
        case ProblemCode.mfaSetupRequired:
          _startOver();
        case ProblemCode.mfaAlreadyEnabled:
          _expiry?.cancel();
          setState(() {
            _step = _Step.password;
            _setup = null;
          });
          await reloadMfa(ref);
        case ProblemCode.mfaCodeInvalid:
          setState(() => _error = e);
          _factor.clearAfterRefusal();
        case _:
          setState(() => _error = e);
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final enabled = watchMfaEnabled(ref);
    final codes = _codes;
    final setup = _setup;
    final Widget body;
    if (_step == _Step.codes && codes != null) {
      body = RecoveryCodesView(
        codes: codes,
        onDone: () {
          ref.read(unsavedRecoveryCodesProvider.notifier).saved();
          _back();
        },
      );
    } else if (enabled) {
      body = MonthraCard(
        child: EmptyState(
          icon: LucideIcons.shieldCheck,
          title: l10n.mfaAlreadyOn,
          action: ShadButton.outline(
            onPressed: _back,
            child: ButtonLabel(l10n.navSettings),
          ),
        ),
      );
    } else if (_step == _Step.scan && setup != null) {
      body = _ScanStep(
        setup: setup,
        form: _form,
        factor: _factor,
        error: _error,
        busy: _busy,
        canOpenApp: _canOpenApp,
        onOpenApp: _openApp,
        onEnable: _enable,
      );
    } else {
      body = MonthraCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_expired) ...[
              FormAlert(message: l10n.mfaSetupExpired, icon: LucideIcons.clock),
              const SizedBox(height: MonthraSpacing.x6),
            ],
            StepUpForm(
              askCode: false,
              submitLabel: l10n.mfaContinue,
              onSubmit: _start,
            ),
          ],
        ),
      );
    }
    return MonthraPage(
      title: l10n.mfaEnableTitle,
      description: switch (_step) {
        _Step.password => l10n.mfaEnablePasswordDescription,
        _Step.scan => l10n.mfaScanDescription,
        _Step.codes => null,
      },
      back: MonthraPageBack(label: l10n.navSettings, onPressed: _back),
      maxWidth: MonthraLayout.maxFormWidth,
      child: body,
    );
  }
}

/// Step 2: add the account to the app, then confirm with its code.
class _ScanStep extends StatelessWidget {
  const new({
    required this.setup,
    required this.form,
    required this.factor,
    required this.error,
    required this.busy,
    required this.canOpenApp,
    required this.onOpenApp,
    required this.onEnable,
  });

  final MfaSetup setup;
  final GlobalKey<ShadFormState> form;
  final SecondFactorController factor;
  final ApiException? error;
  final bool busy;
  final bool canOpenApp;
  final VoidCallback onOpenApp;
  final VoidCallback onEnable;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final l10n = context.l10n;
    final error = this.error;
    final step = theme.textTheme.p.copyWith(
      color: theme.colorScheme.foreground,
    );
    return MonthraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.mfaScanStep, style: step),
          const SizedBox(height: MonthraSpacing.x4),
          Center(
            child: QrCodeView(
              data: setup.otpauthUri,
              semanticLabel: l10n.mfaQrLabel,
            ),
          ),
          if (canOpenApp) ...[
            const SizedBox(height: MonthraSpacing.x4),
            Center(
              child: ShadButton.outline(
                onPressed: onOpenApp,
                leading: const Icon(LucideIcons.externalLink),
                child: ButtonLabel(l10n.mfaOpenAuthenticator),
              ),
            ),
          ],
          const SizedBox(height: MonthraSpacing.x6),
          MfaSecretKey(secret: setup.secret),
          const SizedBox(height: MonthraSpacing.x8),
          Text(l10n.mfaConfirmStep, style: step),
          const SizedBox(height: MonthraSpacing.x4),
          if (error != null) ...[
            FormAlert.error(l10n.apiError(error)),
            const SizedBox(height: MonthraSpacing.x4),
          ],
          ShadForm(
            key: form,
            child: SecondFactorField(
              controller: factor,
              autofocus: false,
              onSubmit: onEnable,
            ),
          ),
          const SizedBox(height: MonthraSpacing.x6),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: ShadButton(
              enabled: !busy,
              onPressed: onEnable,
              child: ButtonLabel(l10n.mfaEnableSubmit),
            ),
          ),
        ],
      ),
    );
  }
}
