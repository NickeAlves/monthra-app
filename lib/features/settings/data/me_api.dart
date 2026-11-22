import 'package:monthra/core/network/api_body.dart';
import 'package:monthra/core/network/api_client.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/core/network/api_problem.dart';
import 'package:monthra/core/network/api_providers.dart';
import 'package:monthra/features/auth/data/models/me.dart';
import 'package:monthra/features/settings/data/models/session_info.dart';
import 'package:monthra/features/settings/domain/preferences_patch.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'me_api.g.dart';

@Riverpod(keepAlive: true)
MeApi meApi(Ref ref) => MeApi(ref.watch(apiClientProvider));

/// The account routes of the API (`/me/*`, the OpenAPI's `me` tag) the
/// settings use. `GET /me` stays in `AuthApi`, which needs it at start-up.
/// Every failure is an `ApiException`.
class MeApi {
  const new(this._api);

  final ApiClient _api;

  /// Changes the display name; the answer is the whole profile, with the
  /// name as the server stored it (trimmed).
  Future<Me> updateName(String name) async {
    final response = await _api.patch<Map<String, Object?>>(
      '/me',
      data: {'name': name},
    );
    return readJson<Me>(response.data, Me.fromJson);
  }

  /// Changes the fields [patch] sets, and only those; the answer holds
  /// every preference as stored now.
  Future<MePreferences> updatePreferences(PreferencesPatch patch) async {
    final response = await _api.patch<Map<String, Object?>>(
      '/me/preferences',
      data: {
        'locale': ?patch.locale?.tag,
        'theme': ?patch.theme?.wire,
        'currency': ?patch.currency?.code,
        'budgetAlerts': ?patch.budgetAlerts,
      },
    );
    return readJson<MePreferences>(response.data, MePreferences.fromJson);
  }

  /// Sets a new password after checking [current]. The server signs out
  /// every other session; this one stays.
  Future<void> changePassword({
    required String current,
    required String next,
  }) => _api.post<void>(
    '/me/password',
    data: {'currentPassword': current, 'newPassword': next},
  );

  /// The active sessions (up to 100), the most recently used first.
  Future<List<SessionInfo>> listSessions() async {
    final response = await _api.get<Map<String, Object?>>('/me/sessions');
    return readJson<List<SessionInfo>>(
      response.data,
      (json) => [
        for (final s in json['sessions']! as List<Object?>)
          SessionInfo.fromJson(s! as Map<String, Object?>),
      ],
    );
  }

  /// Signs one session out. A session already gone (`404`: expired, or
  /// signed out meanwhile) is what was asked for, not a failure.
  Future<void> revokeSession(String id) async {
    try {
      await _api.delete<void>('/me/sessions/${Uri.encodeComponent(id)}');
    } on ApiProblemException catch (e) {
      if (e.code != ProblemCode.notFound) rethrow;
    }
  }

  /// Signs every session out but this one.
  Future<void> revokeOtherSessions() => _api.delete<void>('/me/sessions');
}
