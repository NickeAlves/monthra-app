import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/features/accounts/data/models/account.dart';
import 'package:monthra/features/dashboard/domain/dashboard_view.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Each account's balance on `asOf` in one currency: name, type and amount
/// (a card's debt below zero). An archived account shows while it still
/// holds money, with a badge.
class AccountsCard extends StatelessWidget {
  const new({required this.currency, super.key});

  final CurrencyView currency;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lines = currency.accounts;
    return MonthraCard(
      title: Text(l10n.dashboardAccounts),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, line) in lines.indexed) ...[
            SizedBox(height: i == 0 ? MonthraSpacing.x4 : MonthraSpacing.x3),
            _AccountRow(line: line),
          ],
        ],
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  const new({required this.line});

  final AccountLine line;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;
    final account = line.account;
    final type = account?.type ?? AccountType.unknown;
    return MergeSemantics(
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.muted,
              borderRadius: MonthraRadii.smAll,
            ),
            child: SizedBox.square(
              dimension: CategoryIconSize.md.box,
              child: Icon(
                accountTypeIcon(type),
                size: CategoryIconSize.md.glyph,
                color: scheme.mutedForeground,
              ),
            ),
          ),
          const SizedBox(width: MonthraSpacing.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account?.name ?? l10n.dashboardUnknownAccount,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.label.copyWith(
                    color: scheme.foreground,
                  ),
                ),
                Wrap(
                  spacing: MonthraSpacing.x2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      accountTypeLabel(l10n, type),
                      style: theme.textTheme.caption.copyWith(
                        color: scheme.mutedForeground,
                      ),
                    ),
                    if (account?.archived ?? false)
                      ShadBadge.outline(child: Text(l10n.dashboardArchived)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: MonthraSpacing.x3),
          AmountText(
            line.balance.balance,
            currency: line.balance.currency,
            alignment: AlignmentDirectional.centerEnd,
          ),
        ],
      ),
    );
  }
}

/// The Lucide icon of an account type.
IconData accountTypeIcon(AccountType type) => switch (type) {
  AccountType.checking => LucideIcons.landmark,
  AccountType.savings => LucideIcons.piggyBank,
  AccountType.creditCard => LucideIcons.creditCard,
  AccountType.cash => LucideIcons.banknote,
  AccountType.brokerage => LucideIcons.chartCandlestick,
  AccountType.unknown => LucideIcons.wallet,
};

/// The name of an account type in the UI language.
String accountTypeLabel(AppLocalizations l10n, AccountType type) =>
    switch (type) {
      AccountType.checking => l10n.accountTypeChecking,
      AccountType.savings => l10n.accountTypeSavings,
      AccountType.creditCard => l10n.accountTypeCreditCard,
      AccountType.cash => l10n.accountTypeCash,
      AccountType.brokerage => l10n.accountTypeBrokerage,
      AccountType.unknown => l10n.accountTypeOther,
    };
