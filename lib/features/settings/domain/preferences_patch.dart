import 'package:flutter/foundation.dart';
import 'package:monthra/core/money/currency.dart';
import 'package:monthra/features/settings/preferences/domain/app_locale.dart';
import 'package:monthra/features/settings/preferences/domain/theme_preference.dart';

/// The preferences a `PATCH /me/preferences` can change.
enum PreferenceField { locale, theme, currency, budgetAlerts }

/// Some preferences to change: a null field stays as it is, as the API
/// reads it.
@immutable
class PreferencesPatch {
  const new({this.locale, this.theme, this.currency, this.budgetAlerts});

  static const PreferencesPatch empty = PreferencesPatch();

  final AppLocale? locale;
  final ThemePreference? theme;
  final Currency? currency;
  final bool? budgetAlerts;

  /// The fields this patch sets.
  Set<PreferenceField> get fields => {
    if (locale != null) PreferenceField.locale,
    if (theme != null) PreferenceField.theme,
    if (currency != null) PreferenceField.currency,
    if (budgetAlerts != null) PreferenceField.budgetAlerts,
  };

  bool get isEmpty => fields.isEmpty;

  bool get isNotEmpty => !isEmpty;

  bool has(PreferenceField field) => fields.contains(field);

  /// This patch with the fields [other] sets taken from [other]: the later
  /// choice wins.
  PreferencesPatch merge(PreferencesPatch other) => PreferencesPatch(
    locale: other.locale ?? locale,
    theme: other.theme ?? theme,
    currency: other.currency ?? currency,
    budgetAlerts: other.budgetAlerts ?? budgetAlerts,
  );

  /// This patch without [drop].
  PreferencesPatch without(Iterable<PreferenceField> drop) {
    final gone = drop.toSet();
    return PreferencesPatch(
      locale: gone.contains(PreferenceField.locale) ? null : locale,
      theme: gone.contains(PreferenceField.theme) ? null : theme,
      currency: gone.contains(PreferenceField.currency) ? null : currency,
      budgetAlerts: gone.contains(PreferenceField.budgetAlerts)
          ? null
          : budgetAlerts,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PreferencesPatch &&
      other.locale == locale &&
      other.theme == theme &&
      other.currency == currency &&
      other.budgetAlerts == budgetAlerts;

  @override
  int get hashCode => Object.hash(locale, theme, currency, budgetAlerts);

  @override
  String toString() =>
      'PreferencesPatch(locale: ${locale?.tag}, theme: ${theme?.wire}, '
      'currency: ${currency?.code}, budgetAlerts: $budgetAlerts)';
}
