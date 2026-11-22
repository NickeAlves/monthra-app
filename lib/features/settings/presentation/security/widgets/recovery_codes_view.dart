import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// New recovery codes, shown this once: copy them, tick that they are
/// saved, then [onDone]. Leaving before that asks first (the route's
/// `confirmLeavingRecoveryCodes`).
class RecoveryCodesView extends StatefulWidget {
  const new({required this.codes, required this.onDone, super.key});

  final List<String> codes;
  final VoidCallback onDone;

  @override
  State<RecoveryCodesView> createState() => _RecoveryCodesViewState();
}

class _RecoveryCodesViewState extends State<RecoveryCodesView> {
  bool _saved = false;

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
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: ShadButton.outline(
                onPressed: _copy,
                leading: const Icon(LucideIcons.copy),
                child: ButtonLabel(l10n.recoveryCodesCopy),
              ),
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
