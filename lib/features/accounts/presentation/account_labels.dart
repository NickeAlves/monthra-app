import 'package:flutter/widgets.dart';
import 'package:monthra/features/accounts/data/models/account.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
