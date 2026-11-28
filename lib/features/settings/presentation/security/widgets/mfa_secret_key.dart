import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// The setup key, for an app that cannot scan (and the text alternative of
/// the QR code): in groups of four, with a copy button that copies it
/// without the spaces.
class MfaSecretKey extends StatelessWidget {
  const new({required this.secret, super.key});

  final String secret;

  /// [secret] in groups of four ("JBSW Y3DP ...").
  static String grouped(String secret) => [
    for (var i = 0; i < secret.length; i += 4)
      secret.substring(i, i + 4 > secret.length ? secret.length : i + 4),
  ].join(' ');

  Future<void> _copy(BuildContext context) async {
    final l10n = context.l10n;
    await Clipboard.setData(ClipboardData(text: secret));
    if (!context.mounted) return;
    showMonthraToast(
      context,
      title: l10n.mfaSecretCopied,
      closeLabel: l10n.appClose,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.mfaSecretLabel,
          style: theme.textTheme.small.copyWith(
            color: theme.colorScheme.foreground,
          ),
        ),
        const SizedBox(height: MonthraSpacing.x2),
        Text(
          grouped(secret),
          style: theme.textTheme.amount.copyWith(
            color: theme.colorScheme.foreground,
          ),
        ),
        const SizedBox(height: MonthraSpacing.x2),
        MonthraTapTarget(
          child: ShadButton.outline(
            onPressed: () => _copy(context),
            leading: const Icon(LucideIcons.copy),
            child: ButtonLabel(l10n.mfaCopySecret),
          ),
        ),
      ],
    );
  }
}
