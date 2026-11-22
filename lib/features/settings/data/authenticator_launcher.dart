import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

part 'authenticator_launcher.g.dart';

@Riverpod(keepAlive: true)
AuthenticatorLauncher authenticatorLauncher(Ref ref) =>
    const UrlAuthenticatorLauncher();

/// Hands an `otpauth://` URI to an authenticator app on this device, for a
/// phone that cannot scan its own screen.
abstract interface class AuthenticatorLauncher {
  /// Whether an installed app takes [uri]. Always false on the web.
  Future<bool> canOpen(Uri uri);

  /// Opens [uri] in that app; false when nothing opened.
  Future<bool> open(Uri uri);
}

/// [AuthenticatorLauncher] on url_launcher. `canLaunchUrl` sees the
/// `otpauth` scheme because the Android manifest (`<queries>`) and the iOS
/// Info.plist (`LSApplicationQueriesSchemes`) declare it.
class UrlAuthenticatorLauncher implements AuthenticatorLauncher {
  const new();

  @override
  Future<bool> canOpen(Uri uri) async {
    if (kIsWeb) return false;
    try {
      return await canLaunchUrl(uri);
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<bool> open(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on PlatformException {
      return false;
    }
  }
}
