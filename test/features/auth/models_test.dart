import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/features/auth/data/models/login_result.dart';
import 'package:monthra/features/auth/data/models/me.dart';

import '../../helpers/auth_fixtures.dart';

void main() {
  group('LoginResult', () {
    test('reads a session', () {
      final result = LoginResult.fromJson(sessionJson());
      expect(result, isA<LoginSignedIn>());
      expect((result as LoginSignedIn).session.tokens?.accessToken, 'access-1');
    });

    test("reads a browser's session (no tokens)", () {
      final result = LoginResult.fromJson(sessionJson(tokens: false));
      expect((result as LoginSignedIn).session.tokens, isNull);
    });

    test('reads the two-step challenge', () {
      final result = LoginResult.fromJson(challengeJson());
      expect(result, isA<LoginMfaRequired>());
      expect(
        (result as LoginMfaRequired).challenge,
        const MfaChallenge(mfaToken: 'mfa-token-secret', expiresIn: 300),
      );
    });
  });

  test('Me reads the profile', () {
    final me = Me.fromJson(meJson(locale: 'es-ES', mfa: true));
    expect(me.name, 'Ana');
    expect(me.mfa, const MfaStatus(enabled: true, recoveryCodesRemaining: 10));
    expect(me.preferences.locale, 'es-ES');
    expect(me.createdAt, DateTime.utc(2026, 11, 1, 12));
  });

  test('nothing secret or personal prints', () {
    expect(challenge.toString(), isNot(contains('mfa-token-secret')));
    final me = Me.fromJson(meJson());
    expect(me.toString(), isNot(contains('ana@example.com')));
    expect(me.toString(), isNot(contains('Ana')));
  });
}
