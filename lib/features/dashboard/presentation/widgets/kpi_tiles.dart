import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/core/format/display_format.dart';
import 'package:monthra/core/money/money_format.dart';
import 'package:monthra/features/dashboard/domain/dashboard_view.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// The month's four figures in one currency: the balance on `asOf`, income
/// and expenses (with what recurrences still add) and the result. Four in a
/// row when [wide]; otherwise the balance and the result span the width,
/// with income and expenses side by side between them.
class KpiTiles extends StatelessWidget {
  const new({
    required this.currency,
    required this.asOf,
    required this.wide,
    this.compact = false,
    super.key,
  });

  final CurrencyView currency;
  final DateTime asOf;
  final bool wide;

  /// The other currencies' blocks: the balance in the title size.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final format = DisplayFormat.of(context);
    final s = currency.summary;
    String scheduled(int amount) => amount == 0
        ? l10n.dashboardNothingScheduled
        : l10n.dashboardScheduled(format.money(amount, s.currency));

    final balance = _KpiTile(
      icon: LucideIcons.wallet,
      label: l10n.dashboardBalance,
      amount: AmountText(
        s.balance,
        currency: s.currency,
        size: compact ? AmountSize.title : AmountSize.display,
        animate: true,
      ),
      note: l10n.dashboardBalanceOn(format.day(asOf)),
    );
    final income = _KpiTile(
      icon: LucideIcons.arrowDownLeft,
      label: l10n.dashboardIncome,
      amount: AmountText(
        s.income,
        currency: s.currency,
        // Nothing in or out reads plain, not green or red.
        kind: s.income == 0 ? AmountKind.neutral : AmountKind.income,
        size: AmountSize.title,
        animate: true,
      ),
      note: scheduled(s.scheduled.income),
    );
    final expenses = _KpiTile(
      icon: LucideIcons.arrowUpRight,
      label: l10n.dashboardExpenses,
      amount: AmountText(
        s.expense,
        currency: s.currency,
        kind: s.expense == 0 ? AmountKind.neutral : AmountKind.expense,
        size: AmountSize.title,
        animate: true,
      ),
      note: scheduled(s.scheduled.expense),
    );
    final net = _KpiTile(
      icon: LucideIcons.scale,
      label: l10n.dashboardNet,
      amount: AmountText(
        s.net,
        currency: s.currency,
        kind: switch (s.net) {
          > 0 => AmountKind.income,
          < 0 => AmountKind.expense,
          _ => AmountKind.neutral,
        },
        sign: MoneySign.always,
        size: AmountSize.title,
        animate: true,
      ),
      note: l10n.dashboardNetHint,
    );

    const gap = SizedBox.square(dimension: MonthraSpacing.x4);
    Widget row(List<Widget> tiles) => IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, tile) in tiles.indexed) ...[
            if (i > 0) gap,
            Expanded(child: tile),
          ],
        ],
      ),
    );
    if (wide) {
      return row([balance, income, expenses, net]);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        balance,
        gap,
        row([income, expenses]),
        gap,
        net,
      ],
    );
  }
}

/// One figure: what it is, the amount and a line about it, read as one.
class _KpiTile extends StatelessWidget {
  const new({
    required this.icon,
    required this.label,
    required this.amount,
    required this.note,
  });

  final IconData icon;
  final String label;
  final Widget amount;
  final String note;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final muted = theme.colorScheme.mutedForeground;
    return MergeSemantics(
      child: MonthraCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: MonthraSpacing.x4, color: muted),
                const SizedBox(width: MonthraSpacing.x2),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.label.copyWith(color: muted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: MonthraSpacing.x3),
            amount,
            const SizedBox(height: MonthraSpacing.x1),
            Text(note, style: theme.textTheme.caption.copyWith(color: muted)),
          ],
        ),
      ),
    );
  }
}
