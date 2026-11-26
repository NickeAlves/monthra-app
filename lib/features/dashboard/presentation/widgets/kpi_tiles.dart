import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/core/format/display_format.dart';
import 'package:monthra/core/money/money_format.dart';
import 'package:monthra/features/dashboard/domain/dashboard_view.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// The month's four figures in one currency: the balance on `asOf`, income
/// and expenses (with what recurrences still add) and the result. No cards
/// ("Silêncio"): a strip of figures split by hairlines. Four in a row when
/// [wide], the balance larger; otherwise the balance on top, then income
/// and expenses side by side and the result, between hairlines.
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
      label: l10n.dashboardIncome,
      amount: AmountText(
        s.income,
        currency: s.currency,
        // Nothing in or out reads plain, with no sign.
        kind: s.income == 0 ? AmountKind.neutral : AmountKind.income,
        size: AmountSize.title,
        animate: true,
      ),
      note: scheduled(s.scheduled.income),
    );
    final expenses = _KpiTile(
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

    if (wide) {
      return _Split(
        tiles: [balance, income, expenses, net],
        flex: [if (compact) 2 else 3, 2, 2, 2],
      );
    }
    final scheme = ShadTheme.of(context).colorScheme;
    final rule = ColoredBox(
      color: scheme.border,
      child: const SizedBox(height: 1, width: double.infinity),
    );
    const step = SizedBox(height: MonthraSpacing.x4);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        balance,
        const SizedBox(height: MonthraSpacing.x5),
        rule,
        step,
        _Split(tiles: [income, expenses], flex: const [1, 1]),
        step,
        rule,
        step,
        net,
      ],
    );
  }
}

/// Figures side by side, as tall as the tallest, a hairline between each.
class _Split extends StatelessWidget {
  const new({required this.tiles, required this.flex});

  final List<Widget> tiles;
  final List<int> flex;

  @override
  Widget build(BuildContext context) {
    final scheme = ShadTheme.of(context).colorScheme;
    final gap = context.monthraBreakpoint == MonthraBreakpoint.mobile
        ? MonthraSpacing.x4
        : MonthraSpacing.x6;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, tile) in tiles.indexed) ...[
            if (i > 0) ...[
              SizedBox(width: gap),
              ColoredBox(color: scheme.border, child: const SizedBox(width: 1)),
              SizedBox(width: gap),
            ],
            Expanded(
              flex: flex[i],
              child: Align(
                alignment: AlignmentDirectional.bottomStart,
                child: tile,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// One figure: what it is, the amount and a line about it, read as one.
class _KpiTile extends StatelessWidget {
  const new({required this.label, required this.amount, required this.note});

  final String label;
  final Widget amount;
  final String note;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final muted = theme.colorScheme.mutedForeground;
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: theme.textTheme.label.copyWith(color: muted)),
          const SizedBox(height: MonthraSpacing.x2),
          amount,
          const SizedBox(height: MonthraSpacing.x1),
          Text(note, style: theme.textTheme.caption.copyWith(color: muted)),
        ],
      ),
    );
  }
}
