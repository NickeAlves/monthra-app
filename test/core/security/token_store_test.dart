import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/security/auth_tokens.dart';
import 'package:monthra/core/security/token_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const tokens = AuthTokens(accessToken: 'a1', refreshToken: 'r1');
  const storage = FlutterSecureStorage();

  group('SecureTokenStore', () {
    test('signed out: nothing saved', () async {
      FlutterSecureStorage.setMockInitialValues({});
      expect(await SecureTokenStore().read(), isNull);
    });

    test('saves both tokens in one entry and reads them back', () async {
      FlutterSecureStorage.setMockInitialValues({});
      await SecureTokenStore().write(tokens);

      final raw = await storage.read(key: SecureTokenStore.key);
      expect(jsonDecode(raw!), {'accessToken': 'a1', 'refreshToken': 'r1'});
      // A new store (an app restart) reads them from the platform.
      expect(await SecureTokenStore().read(), tokens);
    });

    test('clear removes the entry', () async {
      FlutterSecureStorage.setMockInitialValues({
        SecureTokenStore.key: jsonEncode(tokens.toJson()),
      });
      final store = SecureTokenStore();
      expect(await store.read(), tokens);

      await store.clear();

      expect(await store.read(), isNull);
      expect(await storage.read(key: SecureTokenStore.key), isNull);
    });

    test(
      'a broken entry is a signed-out device, reported and removed',
      () async {
        FlutterSecureStorage.setMockInitialValues({
          SecureTokenStore.key: '{not json',
        });
        final reported = <FlutterErrorDetails>[];
        final previous = FlutterError.onError;
        FlutterError.onError = reported.add;
        addTearDown(() => FlutterError.onError = previous);

        expect(await SecureTokenStore().read(), isNull);
        expect(reported.single.library, 'token store');
        expect(await storage.read(key: SecureTokenStore.key), isNull);
      },
    );

    test('a write during the first read wins', () async {
      FlutterSecureStorage.setMockInitialValues({
        SecureTokenStore.key: jsonEncode(tokens.toJson()),
      });
      final store = SecureTokenStore();
      const newer = AuthTokens(accessToken: 'a2', refreshToken: 'r2');

      final reading = store.read();
      await store.write(newer);

      expect(await reading, newer);
      expect(await store.read(), newer);
    });

    test('the Keychain entry stays on this device', () {
      expect(
        SecureTokenStore.iosOptions.accessibility,
        KeychainAccessibility.first_unlock_this_device,
      );
      expect(SecureTokenStore.iosOptions.synchronizable, isFalse);
    });
  });

  test('NoTokenStore (web) never holds tokens', () async {
    const store = NoTokenStore();
    expect(await store.read(), isNull);
    expect(() => store.write(tokens), throwsAssertionError);
    await store.clear();
  });
}
