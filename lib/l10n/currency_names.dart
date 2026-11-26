import 'package:monthra/core/money/currency.dart';
import 'package:monthra/l10n/generated/app_localizations.dart';

extension CurrencyNames on AppLocalizations {
  /// The currency's name in the UI language, with its ISO code.
  String currencyName(Currency currency) => switch (currency) {
    Currency.brl => currencyBrl,
    Currency.usd => currencyUsd,
    Currency.eur => currencyEur,
  };
}
