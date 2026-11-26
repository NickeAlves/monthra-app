import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/core/format/display_format.dart';
import 'package:monthra/features/dashboard/domain/dashboard_view.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Twelve months of income and expenses up to the month shown (the last
/// group, highlighted).
class CashFlowCard extends StatelessWidget {
  const new({
    required this.currency,
    required this.narrow,
    this.chartHeight = 220,
    super.key,
  });

  final CurrencyView currency;

  /// A phone: thinner bars.
  final bool narrow;

  /// Taller beside the category card, so the pair has no empty band.
  final double chartHeight;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;
    final format = DisplayFormat.of(context);
    final s = currency.summary;
    final history = s.history;
    final last = history.isEmpty ? null : history.last;
    String value(double v) => format.money(v.round(), s.currency);
    return MonthraCard(
      title: Text(l10n.dashboardCashFlow),
      description: Text(l10n.dashboardLast12Months),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: MonthraSpacing.x4),
          MonthraBarChart(
            semanticLabel: last == null
                ? l10n.dashboardCashFlow
                : l10n.dashboardCashFlowChart(
                    format.month(history.first.month),
                    format.month(last.month),
                    format.month(last.month),
                    format.money(last.income, s.currency),
                    format.money(last.expense, s.currency),
                  ),
            labels: [for (final p in history) format.monthShort(p.month)],
            highlight: history.isEmpty ? null : history.length - 1,
            height: chartHeight,
            barWidth: narrow ? 6 : 10,
            formatAxis: format.axis,
            formatValue: value,
            series: [
              BarSeries(
                name: l10n.dashboardIncome,
                color: scheme.income,
                values: [for (final p in history) p.income.toDouble()],
              ),
              BarSeries(
                name: l10n.dashboardExpenses,
                color: scheme.expense,
                values: [for (final p in history) p.expense.toDouble()],
              ),
            ],
          ),
          const SizedBox(height: MonthraSpacing.x3),
          ExcludeSemantics(
            child: Wrap(
              spacing: MonthraSpacing.x4,
              children: [
                _Key(color: scheme.income, label: l10n.dashboardIncome),
                _Key(color: scheme.expense, label: l10n.dashboardExpenses),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Twelve months of net worth up to the month shown; the months still to
/// come have none.
class NetWorthCard extends StatelessWidget {
  const new({required this.currency, super.key});

  final CurrencyView currency;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;
    final format = DisplayFormat.of(context);
    final s = currency.summary;
    final known = [
      for (final (i, p) in s.history.indexed)
        if (p.netWorth != null) (i, p),
    ];
    Widget body;
    if (known.isEmpty) {
      body = Padding(
        padding: const EdgeInsets.symmetric(vertical: MonthraSpacing.x8),
        child: Center(
          child: Text(
            l10n.dashboardNoNetWorth,
            textAlign: TextAlign.center,
            style: theme.textTheme.muted.copyWith(
              color: scheme.mutedForeground,
            ),
          ),
        ),
      );
    } else {
      final (_, first) = known.first;
      final (lastIndex, last) = known.last;
      body = MonthraLineChart(
        semanticLabel: l10n.dashboardNetWorthChart(
          format.month(first.month),
          format.month(last.month),
          format.money(first.netWorth!, s.currency),
          format.money(last.netWorth!, s.currency),
        ),
        labels: [for (final p in s.history) format.monthShort(p.month)],
        values: [for (final p in s.history) p.netWorth?.toDouble()],
        color: scheme.accentText,
        highlight: lastIndex,
        formatAxis: format.axis,
        formatValue: (v) => format.money(v.round(), s.currency),
      );
    }
    return MonthraCard(
      title: Text(l10n.dashboardNetWorth),
      description: Text(l10n.dashboardLast12Months),
      child: Padding(
        padding: const EdgeInsets.only(top: MonthraSpacing.x4),
        child: body,
      ),
    );
  }
}

/// A series' color and name under a chart.
class _Key extends StatelessWidget {
  const new({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: ensureContrast(color, theme.colorScheme.card),
            borderRadius: MonthraRadii.xsAll,
          ),
          child: const SizedBox.square(dimension: MonthraSpacing.x3),
        ),
        const SizedBox(width: MonthraSpacing.x2),
        Text(
          label,
          style: theme.textTheme.caption.copyWith(
            color: theme.colorScheme.mutedForeground,
          ),
        ),
      ],
    );
  }
}
