import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ProviderListenableSelect;
import 'package:monthra/core/network/api_providers.dart';
import 'package:monthra/features/auth/application/auth_controller.dart';
import 'package:monthra/features/auth/application/auth_state.dart';
import 'package:monthra/features/settings/data/me_api.dart';
import 'package:monthra/features/settings/data/models/session_info.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sessions_controller.g.dart';

/// The signed-in devices of the account, this one first, then the most
/// recently used. Loaded while the sessions card shows; reset when the
/// signed-in person changes. Refusals of [revoke] and [revokeOthers] are
/// thrown for the card to show; the list stays as it was.
@Riverpod(retry: noProviderRetry)
class SessionsController extends _$SessionsController {
  MeApi get _api => ref.read(meApiProvider);

  @override
  Future<List<SessionInfo>> build() async {
    final userId = ref.watch(
      authControllerProvider.select((s) => s is SignedIn ? s.me.id : null),
    );
    if (userId == null) return const [];
    final sessions = await _api.listSessions();
    return [
      ...sessions.where((s) => s.current),
      ...sessions.where((s) => !s.current),
    ];
  }

  /// Signs out the session [id] (another device: this one signs out from
  /// the menu).
  Future<void> revoke(String id) async {
    await _api.revokeSession(id);
    _keep((s) => s.id != id);
  }

  /// Signs out every session but this one.
  Future<void> revokeOthers() async {
    await _api.revokeOtherSessions();
    _keep((s) => s.current);
  }

  void _keep(bool Function(SessionInfo) test) {
    if (!ref.mounted) return;
    final sessions = state.value;
    if (sessions != null) state = AsyncData(sessions.where(test).toList());
  }
}
