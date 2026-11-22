import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_info.freezed.dart';
part 'session_info.g.dart';

/// A signed-in device of the account (`GET /me/sessions`).
@freezed
abstract class SessionInfo with _$SessionInfo {
  const factory({
    required String id,
    required DateTime createdAt,

    /// Moves on each token renewal: accurate to about 15 minutes.
    required DateTime lastUsedAt,
    required DateTime expiresAt,

    /// As the device sent it at sign-in, cut to 256 bytes.
    required String userAgent,
    required String ip,

    /// The session of this app.
    required bool current,
  }) = _SessionInfo;

  const new _();

  factory fromJson(Map<String, Object?> json) => _$SessionInfoFromJson(json);

  // The address is personal data: never in a log (§6.6).
  @override
  String toString() => 'SessionInfo(id: $id, current: $current)';
}
