import 'package:freezed_annotation/freezed_annotation.dart';

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
