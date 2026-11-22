import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/app/router.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/features/auth/application/auth_state.dart';

import '../helpers/auth_fixtures.dart';

void main() {
  group('authRedirect', () {
    final signedIn = SignedIn(me());
    const signedOut = SignedOut();
    const awaiting = AwaitingMfa(challenge);

    final cases = <(String, AuthState, String, String?)>[
      // While the session is unknown, nothing moves.
      ('booting', const AuthBooting(), '/', null),
      (
        'unavailable',
        const AuthUnavailable(NetworkException()),
        '/budgets',
        null,
      ),
      // Signed out.
      ('signed out at home', signedOut, '/', '/login'),
      (
        'signed out on a protected page',
        signedOut,
        '/budgets?month=2026-11',
        '/login?from=%2Fbudgets%3Fmonth%3D2026-11',
      ),
      (
        'signed out on the settings',
        signedOut,
        '/settings',
        '/login?from=%2Fsettings',
      ),
      ('signed in on the settings', signedIn, '/settings', null),
      (
        'signed out under the settings',
        signedOut,
        '/settings/password',
        '/login?from=%2Fsettings%2Fpassword',
      ),
      ('signed out on the sign-in page', signedOut, '/login', null),
      ('signed out on sign-up', signedOut, '/register', null),
      ('signed out on forgot password', signedOut, '/forgot-password', null),
      (
        'MFA page without a challenge',
        signedOut,
        '/login/mfa?from=%2Fbudgets',
        '/login?from=%2Fbudgets',
      ),
      ('MFA page with a challenge', awaiting, '/login/mfa', null),
      ('a challenge does not open home', awaiting, '/', '/login'),
      // Open in either state.
      ('verify link signed out', signedOut, '/verify-email#token=t', null),
      ('reset link signed in', signedIn, '/reset-password#token=t', null),
      ('catalog', signedOut, '/design-system', null),
      // Signed in.
      ('signed in at home', signedIn, '/', null),
      ('signed in on sign-in', signedIn, '/login', '/'),
      (
        'signed in goes back to from',
        signedIn,
        '/login?from=%2Fbudgets%3Fmonth%3D2026-11',
        '/budgets?month=2026-11',
      ),
      ('signed in on the MFA page', signedIn, '/login/mfa?from=%2Fa', '/a'),
      ('signed in on sign-up', signedIn, '/register', '/'),
      // A crafted from never leaves the app.
      ('from another host', signedIn, '/login?from=%2F%2Fevil.com', '/'),
      ('from with a backslash', signedIn, '/login?from=%2F%5Cevil.com', '/'),
      (
        'from with a scheme',
        signedIn,
        '/login?from=https%3A%2F%2Fevil.com',
        '/',
      ),
      ('from relative', signedIn, '/login?from=budgets', '/'),
      ('from to a signed-out page', signedIn, '/login?from=%2Flogin', '/'),
    ];
    for (final (name, auth, location, expected) in cases) {
      test(name, () {
        expect(authRedirect(auth, Uri.parse(location)), expected);
      });
    }
  });

  group('safeReturnPath', () {
    test('keeps a path of the app with its query', () {
      expect(
        safeReturnPath('/budgets?month=2026-11'),
        '/budgets?month=2026-11',
      );
    });

    for (final from in [
      null,
      '',
      'budgets',
      '//evil.com',
      r'/\evil.com',
      '/\t/evil.com',
      'https://evil.com',
      'javascript:alert(1)',
      '/a#token=x',
      '/register',
      '/${'a' * 2048}',
    ]) {
      test('refuses ${from?.substring(0, from.length.clamp(0, 20))}', () {
        expect(safeReturnPath(from), isNull);
      });
    }
  });

  group('linkToken', () {
    test('reads the token of the fragment', () {
      expect(
        linkToken(Uri.parse('/verify-email#token=abc_DEF-123')),
        'abc_DEF-123',
      );
    });

    for (final location in [
      '/verify-email',
      '/verify-email#',
      '/verify-email#token=',
      '/verify-email#other=1',
      '/verify-email#token=%E0%A4%A',
    ]) {
      test('none in $location', () {
        expect(linkToken(Uri.parse(location)), isNull);
      });
    }
  });

  group('SessionKind', () {
    test('notifies the guards only when the kind of session changes', () {
      var notified = 0;
      final kind = SessionKind(const AuthBooting())
        ..addListener(() => notified++)
        ..update(SignedIn(me()));
      addTearDown(kind.dispose);
      expect(notified, 1);
      // A newer profile (a rename): the guards would say the same.
      kind.update(SignedIn(me(name: 'Bia')));
      expect(notified, 1);
      expect((kind.state as SignedIn).me.name, 'Bia');

      kind
        ..update(const SignedOut())
        ..update(const SignedOut(notice: AuthNotice.sessionExpired));
      expect(notified, 2);
      expect((kind.state as SignedOut).notice, AuthNotice.sessionExpired);
    });
  });
}
