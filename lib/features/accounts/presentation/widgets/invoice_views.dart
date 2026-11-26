import 'package:flutter/widgets.dart';
import 'package:monthra/core/dates/year_month.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/core/format/display_format.dart';
import 'package:monthra/core/money/money_format.dart';
import 'package:monthra/features/accounts/data/models/invoice.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// The name of an invoice status in the UI language.
String invoiceStatusLabel(AppLocalizations l10n, InvoiceStatus status) =>
    switch (status) {
      InvoiceStatus.upcoming => l10n.invoiceStatusUpcoming,
      InvoiceStatus.open => l10n.invoiceStatusOpen,
      InvoiceStatus.closed => l10n.invoiceStatusClosed,
      InvoiceStatus.paid => l10n.invoiceStatusPaid,
      InvoiceStatus.overdue => l10n.invoiceStatusOverdue,
      InvoiceStatus.carriedOver => l10n.invoiceStatusCarriedOver,
      InvoiceStatus.unknown => l10n.invoiceStatusUnknown,
    };

/// An invoice's status as a badge: the open one in the accent, an overdue
/// one destructive, the settled and the future ones quiet.
class InvoiceStatusBadge extends StatelessWidget {
  const new(this.status, {super.key});

  final InvoiceStatus status;

  @override
  Widget build(BuildContext context) {
    final label = Text(invoiceStatusLabel(context.l10n, status));
    return switch (status) {
      InvoiceStatus.open => ShadBadge(child: label),
      InvoiceStatus.overdue => ShadBadge.destructive(child: label),
      InvoiceStatus.closed ||
      InvoiceStatus.carriedOver => ShadBadge.secondary(child: label),
      InvoiceStatus.upcoming ||
      InvoiceStatus.paid ||
      InvoiceStatus.unknown => ShadBadge.outline(child: label),
    };
  }
}

/// One invoice in full: its status and dates, then how its total comes
/// about (previous balance, charges, credits) and what is left to pay, or
/// the credit the next invoice starts with.
class InvoiceSummary extends StatelessWidget {
  const new({required this.invoice, super.key});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;
    final format = DisplayFormat.of(context);
    final currency = invoice.currency;
    final credit = invoice.remaining < 0;
    Widget line(
      String label,
      int minor, {
      bool strong = false,
      MoneySign sign = MoneySign.auto,
    }) => MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: MonthraSpacing.x1),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: (strong ? theme.textTheme.label : theme.textTheme.small)
                    .copyWith(
                      color: strong
                          ? scheme.foreground
                          : scheme.mutedForeground,
                    ),
              ),
            ),
            const SizedBox(width: MonthraSpacing.x3),
            AmountText(
              minor,
              currency: currency,
              sign: sign,
              size: strong ? AmountSize.body : AmountSize.small,
              alignment: AlignmentDirectional.centerEnd,
            ),
          ],
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: MonthraSpacing.x3,
          runSpacing: MonthraSpacing.x2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            InvoiceStatusBadge(invoice.status),
            Text(
              l10n.invoiceDates(
                format.day(invoice.closingDate),
                format.day(invoice.dueDate),
              ),
              style: theme.textTheme.small.copyWith(
                color: scheme.mutedForeground,
              ),
            ),
          ],
        ),
        const SizedBox(height: MonthraSpacing.x4),
        line(l10n.invoicePreviousBalance, invoice.previousBalance),
        line(l10n.invoiceCharges, invoice.charges),
        line(l10n.invoiceCredits, -invoice.credits),
        const ShadSeparator.horizontal(
          margin: EdgeInsets.symmetric(vertical: MonthraSpacing.x2),
        ),
        line(l10n.invoiceTotal, invoice.total, strong: true),
        line(l10n.invoicePaid, -invoice.paid),
        const ShadSeparator.horizontal(
          margin: EdgeInsets.symmetric(vertical: MonthraSpacing.x2),
        ),
        line(
          credit ? l10n.invoiceCredit : l10n.invoiceRemaining,
          invoice.remaining.abs(),
          strong: true,
        ),
      ],
    );
  }
}

/// The invoices of a stretch of months, oldest first: each month's name,
/// status and total; [selected] stands out. A tap picks a month.
class InvoiceList extends StatelessWidget {
  const new({
    required this.invoices,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<Invoice> invoices;
  final YearMonth selected;
  final ValueChanged<YearMonth> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final scheme = theme.colorScheme;
    final format = DisplayFormat.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final invoice in invoices)
          MergeSemantics(
            child: Semantics(
              selected: invoice.month == selected,
              button: true,
              child: ShadButton.ghost(
                width: double.infinity,
                height: MonthraLayout.minTouchTarget,
                mainAxisAlignment: MainAxisAlignment.start,
                backgroundColor: invoice.month == selected
                    ? scheme.secondary
                    : null,
                onPressed: () => onSelected(invoice.month),
                expands: true,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        format.month(invoice.month),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.small.copyWith(
                          color: scheme.foreground,
                        ),
                      ),
                    ),
                    const SizedBox(width: MonthraSpacing.x2),
                    InvoiceStatusBadge(invoice.status),
                    const SizedBox(width: MonthraSpacing.x3),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 96),
                      child: AmountText(
                        invoice.total,
                        currency: invoice.currency,
                        size: AmountSize.small,
                        alignment: AlignmentDirectional.centerEnd,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
