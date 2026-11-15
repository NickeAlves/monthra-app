/// Whether this browser may hold a session: the web's session cookies are
/// `HttpOnly`, so the app cannot see them. See [SessionHint].
library;

import 'package:monthra/features/auth/data/session_hint_stub.dart'
    if (dart.library.js_interop) 'package:monthra/features/auth/data/session_hint_web.dart'
    as impl;

/// A mark the web app keeps while it is signed in, so a visit without one
/// opens signed out with no request (no `GET /me` answering 401, no refresh
/// failing, no false "your session expired"). It holds no secret: the
/// session itself stays in the `HttpOnly` cookies. Devices read their
/// `TokenStore` instead.
abstract interface class SessionHint {
  /// The hint of this platform (`localStorage` on the web).
  factory platform() = impl.PlatformSessionHint;

  bool get present;

  set present(bool value);
}

/// Keeps the hint in memory (tests).
final class MemorySessionHint implements SessionHint {
  new({this.present = false});

  @override
  bool present;
}
