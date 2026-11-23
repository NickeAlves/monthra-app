import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/features/dashboard/domain/dashboard_view.dart';
import 'package:monthra/features/dashboard/presentation/widgets/accounts_card.dart';
import 'package:monthra/features/dashboard/presentation/widgets/category_card.dart';
import 'package:monthra/features/dashboard/presentation/widgets/history_cards.dart';
import 'package:monthra/features/dashboard/presentation/widgets/kpi_tiles.dart';
import 'package:monthra/l10n/currency_names.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// The width from which the cards go two by two and the figures four in a
/// row.
const double dashboardTwoColumnsFrom = 880;

/// Below this width the pairs split evenly; from it, 7/12 and 5/12 (the
/// category card stays wide enough for its donut beside the list).
const double dashboardUnevenPairsFrom = 1080;

/// The dashboard of a month: the primary currency in full (figures, the
/// split by category, cash flow, net worth, accounts), then each other
/// currency compact (figures and accounts) under its name. Nothing adds
/// up across currencies.
class DashboardLayout extends StatelessWidget {
  const new({required this.view, super.key});

  final DashboardView view;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final narrow = context.monthraBreakpoint == MonthraBreakpoint.mobile;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final wide = width >= dashboardTwoColumnsFrom;
        final gap = narrow ? MonthraSpacing.x4 : MonthraSpacing.x6;
        final primary = view.currencies.first;
        final (startFlex, endFlex) = width >= dashboardUnevenPairsFrom
            ? (7, 5)
            : (1, 1);
        final categoryWidth = wide
            ? (width - gap) * endFlex / (startFlex + endFlex)
            : width;
        final category = CategoryCard(
          currency: primary,
          wide: categoryWidth >= 420,
          donutSize: categoryWidth >= 480 ? 168 : 136,
        );
        final cashFlow = CashFlowCard(
          currency: primary,
          narrow: narrow,
          // About the height of the category card beside it.
          chartHeight: wide ? 240 : 220,
        );
        final netWorth = NetWorthCard(currency: primary);
        final accounts = AccountsCard(currency: primary);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KpiTiles(currency: primary, asOf: view.asOf, wide: wide),
            SizedBox(height: gap),
            if (wide) ...[
              _Pair(
                gap: gap,
                flex: (startFlex, endFlex),
                start: cashFlow,
                end: category,
              ),
              SizedBox(height: gap),
              _Pair(
                gap: gap,
                flex: (startFlex, endFlex),
                start: netWorth,
                end: accounts,
              ),
            ] else ...[
              category,
              SizedBox(height: gap),
              cashFlow,
              SizedBox(height: gap),
              netWorth,
              SizedBox(height: gap),
              accounts,
            ],
            for (final other in view.currencies.skip(1)) ...[
              SizedBox(height: gap * 2),
              _CurrencyHeading(l10n.currencyName(other.currency)),
              SizedBox(height: gap),
              KpiTiles(
                currency: other,
                asOf: view.asOf,
                wide: wide,
                compact: true,
              ),
              SizedBox(height: gap),
              AccountsCard(currency: other),
            ],
          ],
        );
      },
    );
  }
}

/// Two cards side by side, sharing the width by [flex], as tall as the
/// taller one.
class _Pair extends StatelessWidget {
  const new({
    required this.gap,
    required this.flex,
    required this.start,
    required this.end,
  });

  final double gap;
  final (int, int) flex;
  final Widget start;
  final Widget end;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(flex: flex.$1, child: start),
        SizedBox(width: gap),
        Expanded(flex: flex.$2, child: end),
      ],
    ),
  );
}

/// The name of another currency over its block, on a thin line.
class _CurrencyHeading extends StatelessWidget {
  const new(this.name);

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            name,
            style: theme.textTheme.large.copyWith(
              color: theme.colorScheme.foreground,
            ),
          ),
        ),
        const ShadSeparator.horizontal(
          margin: EdgeInsets.only(top: MonthraSpacing.x2),
        ),
      ],
    );
  }
}
