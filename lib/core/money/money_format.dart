import 'dart:ui';

import 'package:intl/intl.dart';
import 'package:monthra/core/money/currency.dart';

/// When an amount shows its sign.
enum MoneySign {
  /// Only a negative amount: a balance, a total.
  auto,

  /// Plus or minus, never on zero: a flow shown as income or expense.
  always,

  /// Never: the amount of a transaction whose kind says it all.
  never,
}

/// Formats amounts in minor units (cents, as the API sends them) in the
/// user's locale, whatever the currency: `R$ 1.234,56` and `US$ 1.234,56`
/// in pt-BR, `R$1,234.56` and `$1,234.56` in en-US.
abstract final class MoneyFormat {
  /// The typographic minus (U+2212), as wide as the plus sign.
  static const minus = '−';

  /// Largest amount the API stores (server `domain.MaxAmount`). Up to it,
  /// `minor / 100` stays within 2e-5 of the exact value, so rounding to
  /// cents is exact.
  static const maxMinor = 10000000000000;

  /// Locale used when the requested one is unknown to intl.
  static const fallbackLocale = 'pt_BR';

  static final Map<(String, Currency), NumberFormat> _formats = {};

  static String format(
    int minor,
    Currency currency,
    Locale locale, {
    MoneySign sign = MoneySign.auto,
  }) {
    final body = _format(locale, currency).format(minor.abs() / 100);
    final negative = minor < 0;
    return switch (sign) {
      MoneySign.never => body,
      MoneySign.auto => negative ? '$minus$body' : body,
      MoneySign.always when negative => '$minus$body',
      MoneySign.always => minor == 0 ? body : '+$body',
    };
  }

  static NumberFormat _format(Locale locale, Currency currency) {
    final tag = Intl.verifiedLocale(
      Intl.canonicalizedLocale(locale.toLanguageTag()),
      NumberFormat.localeExists,
      onFailure: (_) => fallbackLocale,
    )!;
    return _formats.putIfAbsent(
      (tag, currency),
      () => NumberFormat.currency(
        locale: tag,
        name: currency.code,
        symbol: symbol(currency, tag),
        decimalDigits: currency.decimalDigits,
      ),
    );
  }

  /// The symbol CLDR gives [currency] in the intl locale [tag]. intl's own
  /// table writes a bare `$` for dollars everywhere, which a user holding
  /// reais and dollars could not tell apart outside the US.
  static String symbol(Currency currency, String tag) => switch (currency) {
    Currency.brl => r'R$',
    Currency.eur => '€',
    Currency.usd => tag.endsWith('_US') ? r'$' : r'US$',
  };
}
