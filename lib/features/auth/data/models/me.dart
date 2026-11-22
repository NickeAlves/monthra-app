import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:monthra/core/money/currency.dart';
import 'package:monthra/features/settings/preferences/domain/app_locale.dart';
import 'package:monthra/features/settings/preferences/domain/app_preferences.dart';
import 'package:monthra/features/settings/preferences/domain/theme_preference.dart';

part 'me.freezed.dart';
part 'me.g.dart';

/// The signed-in person (`GET /me`, `Me` in the OpenAPI).
@freezed
abstract class Me with _$Me {
  const factory({
    required String id,
    required String name,
    required String email,
    required bool emailVerified,
    required MfaStatus mfa,
    required MePreferences preferences,
    required DateTime createdAt,
  }) = _Me;

  const new _();

  factory fromJson(Map<String, Object?> json) => _$MeFromJson(json);

  // The name and address are personal data: never in a log (§6.6).
  @override
  String toString() => 'Me(id: $id)';
}

/// Two-step verification on the account.
@freezed
abstract class MfaStatus with _$MfaStatus {
  const factory({required bool enabled, required int recoveryCodesRemaining}) =
      _MfaStatus;

  const new _();

  factory fromJson(Map<String, Object?> json) => _$MfaStatusFromJson(json);
}

/// The profile's preferences, in the API's values (`pt-BR`, `dark`, `BRL`).
@freezed
abstract class MePreferences with _$MePreferences {
  const factory({
    required String locale,
    required String theme,
    required String currency,
    required bool budgetAlerts,
  }) = _MePreferences;

  const new _();

  factory fromJson(Map<String, Object?> json) => _$MePreferencesFromJson(json);
}

/// The profile's preferences in the app's types.
extension MePreferencesValues on MePreferences {
  /// The language and theme the app applies; a value the app does not know
  /// follows the device (language) or the system (theme).
  AppPreferences get app => AppPreferences(
    locale: AppLocale.fromTag(locale),
    theme: ThemePreference.fromWire(theme) ?? ThemePreference.system,
  );

  /// Null when the server sends a currency the app does not know.
  Currency? get currencyValue => Currency.tryCode(currency);
}
