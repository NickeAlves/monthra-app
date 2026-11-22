import 'package:monthra/core/security/auth_tokens.dart';
import 'package:monthra/features/auth/data/models/login_result.dart';
import 'package:monthra/features/auth/data/models/me.dart';

/// `GET /me` as the server writes it.
Map<String, Object?> meJson({
  String id = 'u1',
  String name = 'Ana',
  String locale = 'pt-BR',
  String theme = 'dark',
  String currency = 'BRL',
  bool budgetAlerts = true,
  bool mfa = false,
}) => {
  'id': id,
  'name': name,
  'email': 'ana@example.com',
  'emailVerified': true,
  'mfa': {'enabled': mfa, 'recoveryCodesRemaining': mfa ? 10 : 0},
  'preferences': {
    'locale': locale,
    'theme': theme,
    'currency': currency,
    'budgetAlerts': budgetAlerts,
  },
  'createdAt': '2026-11-01T12:00:00Z',
};

Me me({String name = 'Ana'}) => Me.fromJson(meJson(name: name));

/// A `Session`: with the token pair for a device, the lifetimes alone for
/// a browser.
Map<String, Object?> sessionJson({bool tokens = true, int n = 1}) => {
  'expiresIn': 900,
  'refreshExpiresIn': 2592000,
  if (tokens) ...{
    'tokenType': 'Bearer',
    'accessToken': 'access-$n',
    'refreshToken': 'refresh-$n',
  },
};

Map<String, Object?> challengeJson({int expiresIn = 300}) => {
  'mfaRequired': true,
  'mfaToken': 'mfa-token-secret',
  'expiresIn': expiresIn,
};

const MfaChallenge challenge = MfaChallenge(
  mfaToken: 'mfa-token-secret',
  expiresIn: 300,
);

const AuthTokens savedTokens = AuthTokens(
  accessToken: 'access-0',
  refreshToken: 'refresh-0',
);
