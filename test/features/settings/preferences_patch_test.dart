import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/money/currency.dart';
import 'package:monthra/features/settings/domain/preferences_patch.dart';
import 'package:monthra/features/settings/preferences/domain/app_locale.dart';
import 'package:monthra/features/settings/preferences/domain/theme_preference.dart';

void main() {
  const patch = PreferencesPatch(
    theme: ThemePreference.dark,
    currency: Currency.usd,
  );

  test('lists the fields it sets', () {
    expect(PreferencesPatch.empty.isEmpty, isTrue);
    expect(patch.fields, {PreferenceField.theme, PreferenceField.currency});
    expect(patch.has(PreferenceField.locale), isFalse);
  });

  test('a merge takes the later choices', () {
    expect(
      patch.merge(
        const PreferencesPatch(
          theme: ThemePreference.light,
          locale: AppLocale.enUs,
        ),
      ),
      const PreferencesPatch(
        locale: AppLocale.enUs,
        theme: ThemePreference.light,
        currency: Currency.usd,
      ),
    );
  });

  test('without drops fields', () {
    expect(
      patch.without([PreferenceField.theme, PreferenceField.budgetAlerts]),
      const PreferencesPatch(currency: Currency.usd),
    );
    expect(patch.without(patch.fields), PreferencesPatch.empty);
  });

  test('Currency.tryCode reads the three codes only', () {
    expect(Currency.tryCode('EUR'), Currency.eur);
    expect(Currency.tryCode('GBP'), isNull);
    expect(Currency.tryCode(null), isNull);
  });
}
