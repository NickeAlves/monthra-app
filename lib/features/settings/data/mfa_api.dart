import 'package:monthra/core/network/api_body.dart';
import 'package:monthra/core/network/api_client.dart';
import 'package:monthra/core/network/api_providers.dart';
import 'package:monthra/features/settings/data/models/mfa_setup.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mfa_api.g.dart';

@Riverpod(keepAlive: true)
MfaApi mfaApi(Ref ref) => MfaApi(ref.watch(apiClientProvider));

/// Two-step verification on the signed-in account (`/auth/mfa/*` but
/// `verify`, which belongs to the sign-in). A wrong password or code is a
/// `403` (`password_incorrect`, `mfa_code_invalid`): the session stays.
/// Every failure is an `ApiException`. The secret and the recovery codes
/// are never logged (the client logs no bodies).
class MfaApi {
  const new(this._api);

  final ApiClient _api;

  /// Starts turning MFA on, after checking the password: a new secret to
  /// confirm with [enable] within [MfaSetup.expiresIn].
  Future<MfaSetup> setup(String password) async {
    final response = await _api.post<Map<String, Object?>>(
      '/auth/mfa/setup',
      data: {'password': password},
    );
    return readJson<MfaSetup>(response.data, MfaSetup.fromJson);
  }

  /// Confirms the setup with a first code: MFA is on, and these are the 10
  /// recovery codes, shown only this once.
  Future<List<String>> enable(String code) async {
    final response = await _api.post<Map<String, Object?>>(
      '/auth/mfa/enable',
      data: {'code': code},
    );
    return readJson<List<String>>(response.data, _recoveryCodes);
  }

  /// Turns MFA off with the password and a code (the app's or a recovery
  /// code).
  Future<void> disable({required String password, required String code}) =>
      _api.post<void>(
        '/auth/mfa/disable',
        data: {'password': password, 'code': code},
      );

  /// Replaces every recovery code with 10 new ones, shown only this once;
  /// the old ones stop working.
  Future<List<String>> regenerateRecoveryCodes({
    required String password,
    required String code,
  }) async {
    final response = await _api.post<Map<String, Object?>>(
      '/auth/mfa/recovery-codes',
      data: {'password': password, 'code': code},
    );
    return readJson<List<String>>(response.data, _recoveryCodes);
  }

  static List<String> _recoveryCodes(Map<String, Object?> json) => [
    for (final c in json['recoveryCodes']! as List<Object?>) c! as String,
  ];
}
