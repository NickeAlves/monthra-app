import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/config/env.dart';

Env mobile({
  required String appEnv,
  required String apiBaseUrl,
  required String? flavor,
  String sentryDsn = '',
}) => Env.parse(
  appEnv: appEnv,
  apiBaseUrl: apiBaseUrl,
  sentryDsn: sentryDsn,
  flavor: flavor,
  webOrigin: null,
);

Env web({
  required String appEnv,
  required String page,
  String apiBaseUrl = '',
}) => Env.parse(
  appEnv: appEnv,
  apiBaseUrl: apiBaseUrl,
  sentryDsn: '',
  flavor: null,
  webOrigin: Uri.parse(page),
);

void main() {
  group('Env.parse on mobile', () {
    test('reads a local build', () {
      final env = mobile(
        appEnv: 'local',
        apiBaseUrl: 'http://localhost:8080',
        flavor: 'dev',
      );

      expect(env.appEnv, AppEnv.local);
      expect(env.apiBaseUrl, Uri.parse('http://localhost:8080'));
      expect(env.sentryDsn, isNull);
      expect(env.isProduction, isFalse);
    });

    test('keeps only the origin of the API address', () {
      final env = mobile(
        appEnv: 'production',
        apiBaseUrl: 'https://api.example.com/',
        sentryDsn: 'https://key@sentry.example/1',
        flavor: 'prod',
      );

      expect(env.apiBaseUrl, Uri.parse('https://api.example.com'));
      expect(env.sentryDsn, 'https://key@sentry.example/1');
      expect(env.isProduction, isTrue);
    });

    test('refuses an unknown environment', () {
      for (final appEnv in ['', 'prod', 'Local']) {
        expect(
          () => mobile(
            appEnv: appEnv,
            apiBaseUrl: 'https://api.example.com',
            flavor: 'prod',
          ),
          throwsA(isA<EnvException>()),
          reason: appEnv,
        );
      }
    });

    test('refuses a flavor of another environment', () {
      for (final (appEnv, flavor) in [
        ('local', 'prod'),
        ('staging', 'dev'),
        ('production', 'staging'),
        ('production', null),
      ]) {
        expect(
          () => mobile(
            appEnv: appEnv,
            apiBaseUrl: 'https://api.example.com',
            flavor: flavor,
          ),
          throwsA(isA<EnvException>()),
          reason: '$appEnv on $flavor',
        );
      }
    });

    test('requires an API address', () {
      expect(
        () => mobile(appEnv: 'staging', apiBaseUrl: '', flavor: 'staging'),
        throwsA(
          isA<EnvException>().having(
            (e) => e.message,
            'message',
            contains('env/staging.json'),
          ),
        ),
      );
    });

    test('requires https outside local', () {
      expect(
        () => mobile(
          appEnv: 'staging',
          apiBaseUrl: 'http://api.example.com',
          flavor: 'staging',
        ),
        throwsA(isA<EnvException>()),
      );
    });

    test('refuses an address that is not an origin', () {
      for (final raw in [
        'localhost:8080',
        'ftp://api.example.com',
        'https://',
        'https://api.example.com/api/v1',
        'https://api.example.com?x=1',
        'https://api.example.com#x',
        'https://user:pass@api.example.com',
      ]) {
        expect(
          () => mobile(appEnv: 'local', apiBaseUrl: raw, flavor: 'dev'),
          throwsA(isA<EnvException>()),
          reason: raw,
        );
      }
    });
  });

  group('Env.parse on the web', () {
    test('calls the API on the page origin and ignores API_BASE_URL', () {
      final env = web(
        appEnv: 'staging',
        apiBaseUrl: 'https://elsewhere.example',
        page: 'https://app.example.com/verify-email#token=x',
      );

      expect(env.apiBaseUrl, Uri.parse('https://app.example.com'));
    });

    test('needs no flavor and no API address', () {
      final env = web(appEnv: 'local', page: 'http://localhost:3000/');

      expect(env.appEnv, AppEnv.local);
      expect(env.apiBaseUrl, Uri.parse('http://localhost:3000'));
    });

    test('still refuses an unknown environment', () {
      expect(
        () => web(appEnv: 'dev', page: 'http://localhost:3000/'),
        throwsA(isA<EnvException>()),
      );
    });
  });

  test('maps each environment to its flavor', () {
    expect(AppEnv.values.map((e) => e.flavor), ['dev', 'staging', 'prod']);
  });

  test('compares by value', () {
    Env build() => mobile(
      appEnv: 'local',
      apiBaseUrl: 'http://localhost:8080',
      flavor: 'dev',
    );

    expect(build(), build());
    expect(build().hashCode, build().hashCode);
    expect(
      build(),
      isNot(
        mobile(
          appEnv: 'local',
          apiBaseUrl: 'http://127.0.0.1:8080',
          flavor: 'dev',
        ),
      ),
    );
  });

  test('describes a refused configuration', () {
    expect(const EnvException('boom').toString(), 'EnvException: boom');
  });
}
