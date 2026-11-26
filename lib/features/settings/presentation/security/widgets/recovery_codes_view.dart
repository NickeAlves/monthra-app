import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monthra/core/dates/clock.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/core/files/file_saver.dart';
import 'package:monthra/features/auth/application/auth_controller.dart';
import 'package:monthra/features/auth/application/auth_state.dart';
import 'package:monthra/features/settings/domain/download_names.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// New recovery codes, shown this once: copy them or save them as a text
/// file, tick that they are saved, then [onDone]. Leaving before that asks
/// first (the route's `confirmLeavingRecoveryCodes`). Saving the file does
/// not tick the box: the person says where the codes are.
class RecoveryCodesView extends ConsumerStatefulWidget {
  const new({required this.codes, required this.onDone, super.key});

  final List<String> codes;
  final VoidCallback onDone;

  @override
  ConsumerState<RecoveryCodesView> createState() => _RecoveryCodesViewState();
}

/// The recovery codes' text file, in the UI language: a heading, the
/// account ([email]) and the day [at], the [codes] one per line, and how
/// they work.
String recoveryCodesText(
  AppLocalizations l10n, {
  required String? email,
  required List<String> codes,
  required DateTime at,
}) => [
  l10n.recoveryCodesFileTitle,
  if (email != null) l10n.recoveryCodesFileAccount(email),
  l10n.recoveryCodesFileCreated(at),
  '',
  ...codes,
  '',
  l10n.recoveryCodesFileNote,
  '',
].join('\n');

class _RecoveryCodesViewState extends ConsumerState<RecoveryCodesView> {
  bool _saved = false;
  bool _saving = false;

  Future<void> _copy() async {
    final l10n = context.l10n;
    await Clipboard.setData(ClipboardData(text: widget.codes.join('\n')));
    if (!mounted) return;
    showMonthraToast(
      context,
      title: l10n.recoveryCodesCopied,
      closeLabel: l10n.appClose,
    );
  }

  Future<void> _download() async {
    if (_saving) return;
    final l10n = context.l10n;
    final email = switch (ref.read(authControllerProvider)) {
      SignedIn(:final me) => me.email,
      _ => null,
    };
    final text = recoveryCodesText(
      l10n,
      email: email,
      codes: widget.codes,
      at: ref.read(clockProvider)(),
    );
    setState(() => _saving = true);
    bool? saved;
    try {
      saved = await ref
          .read(fileSaverProvider)
          .save(
            name: recoveryCodesFileName,
            bytes: utf8.encode(text),
            mimeType: 'text/plain',
          );
    } on FileSaveException {
      saved = null;
    }
    if (!mounted) return;
    setState(() => _saving = false);
    if (saved == false) return;
    showMonthraToast(
      context,
      title: saved == null ? l10n.fileSaveFailed : l10n.fileSaved,
      destructive: saved == null,
      closeLabel: l10n.appClose,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final l10n = context.l10n;
    final style = theme.textTheme.amount.copyWith(
      color: theme.colorScheme.foreground,
    );
    return MonthraCard(
      title: Text(l10n.recoveryCodesTitle),
      description: Text(l10n.recoveryCodesDescription),
      // ShadCard sets the content right under the description.
      child: Padding(
        padding: const EdgeInsets.only(top: MonthraSpacing.x6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              container: true,
              label: l10n.recoveryCodesListLabel,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.muted,
                  borderRadius: MonthraRadii.mdAll,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(MonthraSpacing.x4),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const gap = MonthraSpacing.x4;
                      final columns = constraints.maxWidth >= 320 ? 2 : 1;
                      final width =
                          (constraints.maxWidth - gap * (columns - 1)) /
                          columns;
                      return Wrap(
                        spacing: gap,
                        runSpacing: MonthraSpacing.x2,
                        children: [
                          for (final code in widget.codes)
                            SizedBox(
                              width: width,
                              child: Text(code, style: style),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: MonthraSpacing.x4),
            Wrap(
              spacing: MonthraSpacing.x4,
              runSpacing: MonthraSpacing.x2,
              children: [
                ShadButton.outline(
                  onPressed: _copy,
                  leading: const Icon(LucideIcons.copy),
                  child: ButtonLabel(l10n.recoveryCodesCopy),
                ),
                ShadButton.outline(
                  enabled: !_saving,
                  onPressed: _download,
                  leading: const Icon(LucideIcons.download),
                  child: ButtonLabel(l10n.recoveryCodesDownload),
                ),
              ],
            ),
            const SizedBox(height: MonthraSpacing.x6),
            ShadCheckbox(
              value: _saved,
              onChanged: (value) => setState(() => _saved = value),
              label: Text(l10n.recoveryCodesSaved),
            ),
            const SizedBox(height: MonthraSpacing.x4),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: ShadButton(
                enabled: _saved,
                onPressed: widget.onDone,
                child: ButtonLabel(l10n.recoveryCodesDone),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
