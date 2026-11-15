/// The routes the client itself knows about, relative to `/api/v1`.
abstract final class ApiRoutes {
  static const csrf = '/auth/csrf';
  static const refresh = '/auth/refresh';

  /// The routes that take no session: no `Authorization` header, and a
  /// `401` there is an answer (wrong password, expired MFA challenge), not
  /// an expired session to renew. Every other route needs a session.
  static const Set<String> public = {
    csrf,
    refresh,
    '/auth/register',
    '/auth/verify-email',
    '/auth/verify-email/resend',
    '/auth/login',
    '/auth/forgot-password',
    '/auth/reset-password',
    '/auth/mfa/verify',
  };

  static bool isPublic(String path) {
    final query = path.indexOf('?');
    return public.contains(query < 0 ? path : path.substring(0, query));
  }
}

/// The HTTP methods that change state: the browser sends the CSRF token
/// on these (§6.3).
bool isMutating(String method) => switch (method.toUpperCase()) {
  'GET' || 'HEAD' || 'OPTIONS' || 'TRACE' => false,
  _ => true,
};
