import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:monthra/core/security/auth_tokens.dart';

/// Where a native session's tokens live (§6.2). On the web the tokens are
/// `HttpOnly` cookies the app never sees: there the store is [NoTokenStore].
abstract interface class TokenStore {
  /// The saved tokens, or null when signed out.
  Future<AuthTokens?> read();

  /// Saves [tokens]; the call completes once they are on disk.
  Future<void> write(AuthTokens tokens);

  Future<void> clear();
}

/// The Keychain (iOS) or the Keystore-backed storage (Android), with an
/// in-memory copy so a request never waits on the platform channel twice.
final class SecureTokenStore implements TokenStore {
  new([this._storage = const FlutterSecureStorage(iOptions: iosOptions)]);

  /// Readable after the first unlock (background refreshes), never synced
  /// to iCloud or moved to another device.
  static const iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  );

  @visibleForTesting
  static const key = 'auth.tokens';

  final FlutterSecureStorage _storage;
  AuthTokens? _cache;
  bool _loaded = false;
  Future<AuthTokens?>? _loading;

  @override
  Future<AuthTokens?> read() {
    if (_loaded) return Future.value(_cache);
    return _loading ??= _load();
  }

  Future<AuthTokens?> _load() async {
    AuthTokens? stored;
    var broken = false;
    try {
      final raw = await _storage.read(key: key);
      stored = raw == null ? null : AuthTokens.fromJson(_decode(raw));
    } on Object catch (error, stack) {
      // An unreadable entry (a Keystore reset, a broken value) is a
      // signed-out device, not a crash.
      _report(error, stack, 'reading the session tokens');
      broken = true;
    }
    _loading = null;
    // A write or clear while reading is newer than what was on disk.
    if (_loaded) return _cache;
    _cache = stored;
    _loaded = true;
    if (broken) await _deleteQuietly();
    return _cache;
  }

  @override
  Future<void> write(AuthTokens tokens) async {
    _cache = tokens;
    _loaded = true;
    await _storage.write(key: key, value: jsonEncode(tokens.toJson()));
  }

  @override
  Future<void> clear() async {
    _cache = null;
    _loaded = true;
    await _deleteQuietly();
  }

  Future<void> _deleteQuietly() async {
    try {
      await _storage.delete(key: key);
    } on PlatformException catch (error, stack) {
      _report(error, stack, 'deleting the session tokens');
    }
  }

  static Map<String, Object?> _decode(String raw) =>
      jsonDecode(raw) as Map<String, Object?>;

  static void _report(Object error, StackTrace stack, String context) =>
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'token store',
          context: ErrorDescription(context),
        ),
      );
}

/// The web's store: nothing to keep, since the browser holds the session
/// cookies. Writing is a bug, so it fails in debug builds.
final class NoTokenStore implements TokenStore {
  const new();

  @override
  Future<AuthTokens?> read() async => null;

  @override
  Future<void> write(AuthTokens tokens) async {
    assert(false, 'the web never stores tokens: they are HttpOnly cookies');
  }

  @override
  Future<void> clear() async {}
}

/// Keeps the tokens in memory (tests).
final class MemoryTokenStore implements TokenStore {
  new([this._tokens]);

  AuthTokens? _tokens;

  @override
  Future<AuthTokens?> read() async => _tokens;

  @override
  Future<void> write(AuthTokens tokens) async => _tokens = tokens;

  @override
  Future<void> clear() async => _tokens = null;
}
