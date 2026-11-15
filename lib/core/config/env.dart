import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The deployment the build targets (`APP_ENV`), shared with the server and
/// the infra repos.
enum AppEnv {
  local,
  staging,
  production;

  /// The mobile flavor built for this environment (`--flavor`).
  String get flavor => switch (this) {
    AppEnv.local => 'dev',
    AppEnv.staging => 'staging',
    AppEnv.production => 'prod',
  };
}

/// A build configuration that cannot run: the app refuses to start.
class EnvException implements Exception {
  const new(this.message);

  final String message;

  @override
  String toString() => 'EnvException: $message';
}

/// Build-time configuration, read from `--dart-define-from-file=env/<env>.json`.
@immutable
class Env {
  const new({required this.appEnv, required this.apiBaseUrl, this.sentryDsn});

  /// Reads the compile-time defines of this build.
  factory fromEnvironment() => Env.parse(
    appEnv: const String.fromEnvironment('APP_ENV'),
    apiBaseUrl: const String.fromEnvironment('API_BASE_URL'),
    sentryDsn: const String.fromEnvironment('SENTRY_DSN'),
    flavor: appFlavor,
    webOrigin: kIsWeb ? Uri.base : null,
  );

  /// Validates raw values. [webOrigin] is the page's address on the web and
  /// null on mobile; [flavor] is `appFlavor` (null on the web).
  ///
  /// Every parameter is required: the analyzer sees the compile-time defines
  /// as empty, so defaults would make it flag the real values as redundant.
  ///
  /// The web app always calls the API on its own origin: the auth cookies
  /// are `SameSite=Strict`, and the CSP stays at `connect-src 'self'`. A
  /// proxy routes `/api` (web_dev_config.yaml locally, nginx in Docker, the
  /// infra proxy on a deployment), so `API_BASE_URL` only matters on mobile.
  factory parse({
    required String appEnv,
    required String apiBaseUrl,
    required String sentryDsn,
    required String? flavor,
    required Uri? webOrigin,
  }) {
    final env = AppEnv.values.asNameMap()[appEnv];
    if (env == null) {
      throw EnvException(
        'APP_ENV must be local, staging or production, got "$appEnv": '
        'build with --dart-define-from-file=env/<env>.json',
      );
    }
    final dsn = sentryDsn.isEmpty ? null : sentryDsn;

    if (webOrigin != null) {
      return Env(
        appEnv: env,
        apiBaseUrl: Uri.parse(webOrigin.origin),
        sentryDsn: dsn,
      );
    }

    if (flavor != env.flavor) {
      throw EnvException(
        'APP_ENV $appEnv runs on the ${env.flavor} flavor, '
        'got ${flavor ?? 'none'}: build with --flavor ${env.flavor}',
      );
    }
    return Env(
      appEnv: env,
      apiBaseUrl: _parseApiBaseUrl(env, apiBaseUrl),
      sentryDsn: dsn,
    );
  }

  static Uri _parseApiBaseUrl(AppEnv env, String raw) {
    if (raw.isEmpty) {
      throw EnvException(
        'API_BASE_URL is required on mobile (env/${env.name}.json)',
      );
    }
    final uri = Uri.tryParse(raw);
    final isHttp =
        uri != null && (uri.isScheme('http') || uri.isScheme('https'));
    if (!isHttp ||
        uri.host.isEmpty ||
        uri.hasQuery ||
        uri.hasFragment ||
        uri.userInfo.isNotEmpty ||
        (uri.path.isNotEmpty && uri.path != '/')) {
      throw EnvException(
        'API_BASE_URL must be an origin like https://api.example.com, '
        'got "$raw"',
      );
    }
    if (env != AppEnv.local && !uri.isScheme('https')) {
      throw EnvException('API_BASE_URL must use https in ${env.name}');
    }
    return Uri.parse(uri.origin);
  }

  final AppEnv appEnv;

  /// The API origin; every route lives under `/api/v1` ([apiRoot]).
  final Uri apiBaseUrl;

  /// The base of every API route.
  Uri get apiRoot => apiBaseUrl.replace(path: '/api/v1');

  /// Error reporting, unused until a provider is wired.
  final String? sentryDsn;

  bool get isProduction => appEnv == AppEnv.production;

  @override
  bool operator ==(Object other) =>
      other is Env &&
      other.appEnv == appEnv &&
      other.apiBaseUrl == apiBaseUrl &&
      other.sentryDsn == sentryDsn;

  @override
  int get hashCode => Object.hash(appEnv, apiBaseUrl, sentryDsn);
}
