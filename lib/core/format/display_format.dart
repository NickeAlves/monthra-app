import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:monthra/core/dates/year_month.dart';
import 'package:monthra/core/money/currency.dart';
import 'package:monthra/core/money/money_format.dart';

/// The dashboard's numbers and dates in the UI locale.
@immutable
final class DisplayFormat {
  const new _(this.locale);

  factory of(BuildContext context) =>
      DisplayFormat._(Localizations.localeOf(context));

  final Locale locale;

  String get _tag => locale.toLanguageTag();

  String money(
    int minor,
    Currency currency, {
    MoneySign sign = MoneySign.auto,
  }) => MoneyFormat.format(minor, currency, locale, sign: sign);

  /// An axis amount, rounded and without a symbol (`8,5 mil`).
  String axis(double minor) => MoneyFormat.compact(minor.round(), locale);

  /// `Novembro de 2026`, as a label of its own (sentence case).
  String month(YearMonth month) => toBeginningOfSentenceCase(
    DateFormat.yMMMM(_tag).format(month.firstDay),
    _tag,
  );

  /// `nov.`, under a chart's bar.
  String monthShort(YearMonth month) =>
      DateFormat.MMM(_tag).format(month.firstDay);

  /// `23 de nov. de 2026`.
  String day(DateTime day) => DateFormat.yMMMd(_tag).format(day);

  /// `18%` (`18 %` in es-ES) for a share from 0 to 1.
  String percent(double share) =>
      NumberFormat.percentPattern(_tag).format(share);
}
