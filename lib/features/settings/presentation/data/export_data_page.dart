import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:monthra/app/routes.dart';
import 'package:monthra/core/dates/clock.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/core/files/file_saver.dart';
import 'package:monthra/core/forms/form_alert.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/core/network/api_problem.dart';
import 'package:monthra/features/auth/application/auth_controller.dart';
import 'package:monthra/features/auth/application/auth_state.dart';
import 'package:monthra/features/settings/data/me_api.dart';
import 'package:monthra/features/settings/domain/download_names.dart';
import 'package:monthra/features/settings/presentation/data/widgets/data_point.dart';
import 'package:monthra/features/settings/presentation/security/mfa_profile.dart';
import 'package:monthra/features/settings/presentation/security/widgets/step_up_form.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Exports every record of the account (`POST /me/export`, LGPD) after the
/// password and, with two-step verification on, a code; then hands the ZIP
/// to the [FileSaver].
///
/// The archive stays in this page's state until it is left, so a cancelled
/// or failed save goes again without a new export (each one emails the
/// owner and counts toward the hourly limit). It never reaches a provider
/// or a log: it is the person's financial records.
class ExportDataPage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<ExportDataPage> createState() => _ExportDataPageState();
}

enum _Save { saving, saved, notSaved, failed }

class _ExportDataPageState extends ConsumerState<ExportDataPage> {
  ({String name, Uint8List bytes})? _file;
  _Save? _save;

  void _back() => context.go(AppRoutes.settings);

  Future<void> _export(String password, String code) async {
    final Uint8List bytes;
    try {
      bytes = await ref
          .read(meApiProvider)
          .exportData(password: password, code: code);
    } on ApiProblemException catch (e) {
      // No code sent, yet one was asked: two-step verification was turned
      // on elsewhere. Once the profile says so, the form asks for it.
      if (code.isEmpty && e.code == ProblemCode.mfaCodeInvalid) {
        await reloadMfa(ref);
      }
      rethrow;
    }
    if (!mounted) return;
    setState(
      () => _file = (
        name: exportFileName(ref.read(clockProvider)()),
        bytes: bytes,
      ),
    );
    unawaited(_saveFile());
  }

  Future<void> _saveFile() async {
    final file = _file;
    if (file == null || _save == _Save.saving) return;
    setState(() => _save = _Save.saving);
    _Save outcome;
    try {
      final saved = await ref
          .read(fileSaverProvider)
          .save(
            name: file.name,
            bytes: file.bytes,
            mimeType: 'application/zip',
          );
      outcome = saved ? _Save.saved : _Save.notSaved;
    } on FileSaveException {
      outcome = _Save.failed;
    }
    if (!mounted) return;
    setState(() => _save = outcome);
    if (outcome == _Save.saved) {
      final l10n = context.l10n;
      showMonthraToast(
        context,
        title: l10n.fileSaved,
        closeLabel: l10n.appClose,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final file = _file;
    return MonthraPage(
      title: l10n.exportDataTitle,
      description: l10n.exportDataDescription,
      back: MonthraPageBack(label: l10n.navSettings, onPressed: _back),
      maxWidth: MonthraLayout.maxFormWidth,
      child: file == null ? _form(context) : _ready(context, file.name),
    );
  }

  Widget _form(BuildContext context) {
    final l10n = context.l10n;
    final email = ref.watch(
      authControllerProvider.select((s) => s is SignedIn ? s.me.email : null),
    );
    const between = SizedBox(height: MonthraSpacing.x4);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MonthraCard(
          title: Text(l10n.exportDataContentsTitle),
          // ShadCard sets the content right under the title.
          child: Padding(
            padding: const EdgeInsets.only(top: MonthraSpacing.x4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DataPoint(
                  icon: LucideIcons.fileJson,
                  text: l10n.exportDataIncludes,
                ),
                between,
                DataPoint(
                  icon: LucideIcons.lock,
                  text: l10n.exportDataExcludes,
                ),
                if (email != null) ...[
                  between,
                  DataPoint(
                    icon: LucideIcons.mail,
                    text: l10n.exportDataEmail(email),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: MonthraSpacing.x6),
        MonthraCard(
          title: Text(l10n.exportDataConfirmTitle),
          child: Padding(
            padding: const EdgeInsets.only(top: MonthraSpacing.x6),
            child: StepUpForm(
              askCode: watchMfaEnabled(ref),
              submitLabel: l10n.exportDataSubmit,
              busyLabel: l10n.exportDataBusy,
              onSubmit: _export,
            ),
          ),
        ),
      ],
    );
  }

  Widget _ready(BuildContext context, String name) {
    final l10n = context.l10n;
    final save = _save;
    return MonthraCard(
      title: Text(l10n.exportDataReadyTitle),
      description: Text(l10n.exportDataReadyDescription(name)),
      child: Padding(
        padding: const EdgeInsets.only(top: MonthraSpacing.x6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (save == _Save.notSaved || save == _Save.failed) ...[
              if (save == _Save.failed)
                FormAlert(
                  message: l10n.fileSaveFailed,
                  destructive: true,
                  icon: LucideIcons.circleAlert,
                )
              else
                FormAlert(message: l10n.fileNotSaved),
              const SizedBox(height: MonthraSpacing.x6),
            ],
            Wrap(
              spacing: MonthraSpacing.x4,
              runSpacing: MonthraSpacing.x2,
              children: [
                ShadButton(
                  enabled: save != _Save.saving,
                  onPressed: _saveFile,
                  leading: const Icon(LucideIcons.download),
                  child: ButtonLabel(l10n.exportDataSave),
                ),
                ShadButton.outline(
                  onPressed: _back,
                  child: ButtonLabel(l10n.navSettings),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
