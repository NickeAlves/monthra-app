import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/core/format/display_format.dart';
import 'package:monthra/core/money/currency.dart';
import 'package:monthra/features/dashboard/domain/dashboard_view.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Which flow the category card splits.
enum CategoryFlow { expenses, income }

/// The month split by category: a donut and the list of parts (a dot of
/// the slice's color, name, entries, amount and share), expenses or income.
/// The slices are ranked greens ("Silêncio": `chartRamp`, "others" in grey),
/// not the categories' own colors. The donut sits beside the list when
/// [wide], above it otherwise.
class CategoryCard extends StatefulWidget {
  const new({
    required this.currency,
    required this.wide,
    this.donutSize = 168,
    super.key,
  });

  final CurrencyView currency;
  final bool wide;

  /// The donut's side; smaller beside the list on a narrow card.
  final double donutSize;

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  CategoryFlow _flow = CategoryFlow.expenses;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final l10n = context.l10n;
    final format = DisplayFormat.of(context);
    final currency = widget.currency.currency;
    final slices = switch (_flow) {
      CategoryFlow.expenses => widget.currency.expenses,
      CategoryFlow.income => widget.currency.income,
    };
    final total = slices.fold(0, (sum, s) => sum + s.amount);
    final scheme = theme.colorScheme;
    final ramp = scheme.chartRamp;
    // The parts come largest first, "others" last.
    Color colorOf(int index, CategorySlice slice) =>
        slice.kind == CategorySliceKind.category
        ? ramp[index.clamp(0, ramp.length - 1)]
        : scheme.chartMuted;

    Widget body;
    if (slices.isEmpty) {
      body = Padding(
        padding: const EdgeInsets.symmetric(vertical: MonthraSpacing.x8),
        child: Center(
          child: Text(
            _flow == CategoryFlow.expenses
                ? l10n.dashboardNoExpenses
                : l10n.dashboardNoIncome,
            textAlign: TextAlign.center,
            style: theme.textTheme.muted.copyWith(
              color: theme.colorScheme.mutedForeground,
            ),
          ),
        ),
      );
    } else {
      final parts = [
        for (final s in slices)
          l10n.dashboardCategoryShare(
            _name(l10n, s),
            format.money(s.amount, currency),
            format.percent(s.amount / total),
          ),
      ].join('; ');
      final donut = MonthraDonutChart(
        size: widget.wide ? widget.donutSize : 168,
        semanticLabel: _flow == CategoryFlow.expenses
            ? l10n.dashboardExpensesChart(parts)
            : l10n.dashboardIncomeChart(parts),
        slices: [
          for (final (i, s) in slices.indexed)
            DonutSlice(value: s.amount.toDouble(), color: colorOf(i, s)),
        ],
        center: AmountText(
          total,
          currency: currency,
          size: AmountSize.small,
          alignment: Alignment.center,
        ),
      );
      final legend = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, s) in slices.indexed) ...[
            if (i > 0) const SizedBox(height: MonthraSpacing.x3),
            _SliceRow(
              slice: s,
              color: colorOf(i, s),
              name: _name(l10n, s),
              currency: currency,
              share: format.percent(s.amount / total),
            ),
          ],
        ],
      );
      body = widget.wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                donut,
                const SizedBox(width: MonthraSpacing.x6),
                Expanded(child: legend),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: donut),
                const SizedBox(height: MonthraSpacing.x6),
                legend,
              ],
            );
    }

    return MonthraSection(
      title: Text(l10n.dashboardByCategory),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FlowSwitch(
            flow: _flow,
            onChanged: (flow) => setState(() => _flow = flow),
          ),
          const SizedBox(height: MonthraSpacing.x5),
          body,
        ],
      ),
    );
  }

  static String _name(AppLocalizations l10n, CategorySlice s) =>
      switch (s.kind) {
        CategorySliceKind.category => s.category!.name,
        CategorySliceKind.others => l10n.dashboardOtherCategories,
        CategorySliceKind.unknown => l10n.dashboardUnknownCategory,
      };
}

/// Expenses or income: one selected, as the theme picker does it (one
/// node per option, selected state included).
class _FlowSwitch extends StatelessWidget {
  const new({required this.flow, required this.onChanged});

  final CategoryFlow flow;
  final ValueChanged<CategoryFlow> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    Widget option(CategoryFlow value, String label) {
      final selected = value == flow;
      void select() => onChanged(value);
      final child = ButtonLabel(label);
      return MonthraTapTarget(
        child: Semantics(
          selected: selected,
          inMutuallyExclusiveGroup: true,
          child: selected
              ? ShadButton.secondary(onPressed: select, child: child)
              : ShadButton.ghost(onPressed: select, child: child),
        ),
      );
    }

    return Semantics(
      container: true,
      label: l10n.dashboardCategoryKind,
      child: Wrap(
        children: [
          option(CategoryFlow.expenses, l10n.dashboardExpenses),
          option(CategoryFlow.income, l10n.dashboardIncome),
        ],
      ),
    );
  }
}

/// A part of the month: the category, its entries, amount and share.
class _SliceRow extends StatelessWidget {
  const new({
    required this.slice,
    required this.color,
    required this.name,
    required this.currency,
    required this.share,
  });

  final CategorySlice slice;

  /// The slice's color in the donut.
  final Color color;
  final String name;
  final Currency currency;
  final String share;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final l10n = context.l10n;
    final muted = theme.textTheme.caption.copyWith(
      color: theme.colorScheme.mutedForeground,
    );
    return MergeSemantics(
      child: Row(
        children: [
          ExcludeSemantics(
            child: SizedBox.square(
              dimension: MonthraSpacing.x2,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ),
          ),
          const SizedBox(width: MonthraSpacing.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.label.copyWith(
                    color: theme.colorScheme.foreground,
                  ),
                ),
                Text(l10n.dashboardEntries(slice.count), style: muted),
              ],
            ),
          ),
          const SizedBox(width: MonthraSpacing.x3),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AmountText(
                slice.amount,
                currency: currency,
                size: AmountSize.small,
                alignment: AlignmentDirectional.centerEnd,
              ),
              Text(share, style: muted),
            ],
          ),
        ],
      ),
    );
  }
}
