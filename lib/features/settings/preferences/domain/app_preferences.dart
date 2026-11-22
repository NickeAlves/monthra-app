import 'package:flutter/foundation.dart';
import 'package:monthra/features/settings/preferences/domain/app_locale.dart';
import 'package:monthra/features/settings/preferences/domain/theme_preference.dart';

/// The preferences the app applies on its own (§7.6), kept on the device
/// too. The default currency and the budget alerts live only in the
/// profile (`Me.preferences`).
@immutable
class AppPreferences {
  const new({this.locale, this.theme = ThemePreference.system});

  /// The chosen language; null follows the device until the person picks
  /// one or signs in (the profile always has one).
  final AppLocale? locale;

  final ThemePreference theme;

  /// A copy with [locale] (null included) and/or [theme] replaced.
  AppPreferences copyWith({
    ValueGetter<AppLocale?>? locale,
    ThemePreference? theme,
  }) => AppPreferences(
    locale: locale == null ? this.locale : locale(),
    theme: theme ?? this.theme,
  );

  @override
  bool operator ==(Object other) =>
      other is AppPreferences && other.locale == locale && other.theme == theme;

  @override
  int get hashCode => Object.hash(locale, theme);

  @override
  String toString() =>
      'AppPreferences(locale: ${locale?.tag}, theme: ${theme.wire})';
}
