import 'dart:async';

import 'auth_fixtures.dart';
import 'fake_api.dart';

/// A small API that keeps a profile: `GET /me`, `PATCH /me` (the name,
/// trimmed), `PATCH /me/preferences` (merged), sign-in without MFA,
/// sign-out and the CSRF token. Anything else is a `404`.
///
/// [hold] makes the next `PATCH` wait for a completer; [fail] answers the
/// next request to a path with a given reply.
final class ProfileServer {
  new({Map<String, Object?>? me}) : me = me ?? meJson();

  /// The profile as stored now (`GET /me` shape).
  Map<String, Object?> me;

  late final FakeAdapter adapter = FakeAdapter(_handle);

  final List<Completer<void>> _gates = [];
  final Map<String, List<Reply>> _failures = {};

  /// The next `PATCH` waits until the returned completer completes.
  Completer<void> hold() {
    final gate = Completer<void>();
    _gates.add(gate);
    return gate;
  }

  /// The next request to [path] (`/api/v1/...`) gets [reply] instead.
  void fail(String path, Reply reply) => (_failures[path] ??= []).add(reply);

  /// The bodies of the `PATCH /me/preferences` sent so far, in order.
  List<Map<String, Object?>> get preferencePatches => [
    for (final r in adapter.sent)
      if (r.method == 'PATCH' && r.path == '/api/v1/me/preferences')
        Map<String, Object?>.of(r.data! as Map<String, Object?>),
  ];

  Map<String, Object?> get preferences =>
      me['preferences']! as Map<String, Object?>;

  Future<Reply> _handle(SentRequest r) async {
    if (r.method == 'PATCH' && _gates.isNotEmpty) {
      await _gates.removeAt(0).future;
    }
    final failures = _failures[r.path];
    if (failures != null && failures.isNotEmpty) return failures.removeAt(0);
    final body = r.data is Map
        ? r.data! as Map<String, Object?>
        : const <String, Object?>{};
    switch ((r.method, r.path)) {
      case ('GET', '/api/v1/auth/csrf'):
        return Reply.json({'csrfToken': 'csrf'});
      case ('POST', '/api/v1/auth/login'):
        return Reply.json(sessionJson());
      case ('POST', '/api/v1/auth/logout'):
        return const Reply(204);
      case ('GET', '/api/v1/me'):
        return Reply.json(me);
      case ('PATCH', '/api/v1/me'):
        me = {...me, 'name': (body['name']! as String).trim()};
        return Reply.json(me);
      case ('PATCH', '/api/v1/me/preferences'):
        me = {
          ...me,
          'preferences': {...preferences, ...body},
        };
        return Reply.json(preferences);
    }
    return Reply.problem(404, 'not_found');
  }
}
