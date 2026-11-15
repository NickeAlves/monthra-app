import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/config/env.dart';

Env mobile({
  required String appEnv,
  required String apiBaseUrl,
  required String? flavor,
  String sentryDsn = '',
  String appPublicUrl = '',
  String turnstileSiteKey = '',
}) => Env.parse(
  appEnv: appEnv,
  apiBaseUrl: apiBaseUrl,
  sentryDsn: sentryDsn,
  appPublicUrl: appPublicUrl,
  turnstileSiteKey: turnstileSiteKey,
  flavor: flavor,
  webOrigin: null,
);

Env web({
  required String appEnv,
  required String page,
  String apiBaseUrl = '',
  String appPublicUrl = '',
  String turnstileSiteKey = '',
}) => Env.parse(
  appEnv: appEnv,
  apiBaseUrl: apiBaseUrl,
  sentryDsn: '',
  appPublicUrl: appPublicUrl,
  turnstileSiteKey: turnstileSiteKey,
  flavor: null,
  webOrigin: Uri.parse(page),
);

const testSiteKey = '1x00000000000000000000AA';

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
      expect(env.apiRoot, Uri.parse('http://localhost:8080/api/v1'));
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

  group('the captcha page', () {
    test('a device loads it from APP_PUBLIC_URL', () {
      final env = mobile(
        appEnv: 'production',
        apiBaseUrl: 'https://api.example.com',
        flavor: 'prod',
        appPublicUrl: 'https://app.example.com/',
        turnstileSiteKey: '0x4AAAAAAAB_c-d',
      );

      expect(env.appPublicUrl, Uri.parse('https://app.example.com'));
      expect(env.turnstileSiteKey, '0x4AAAAAAAB_c-d');
      expect(
        env.captchaPage,
        Uri.parse('https://app.example.com/turnstile.html'),
      );
    });

    test('the web serves it from the page origin', () {
      final env = web(
        appEnv: 'staging',
        page: 'https://app.example.com/login?from=%2F',
        appPublicUrl: 'https://elsewhere.example',
        turnstileSiteKey: testSiteKey,
      );

      expect(
        env.captchaPage,
        Uri.parse('https://app.example.com/turnstile.html'),
      );
    });

    test('is absent without a site key or, on a device, an address', () {
      expect(
        web(appEnv: 'local', page: 'http://localhost:3000/').captchaPage,
        isNull,
      );
      final noAddress = mobile(
        appEnv: 'local',
        apiBaseUrl: 'http://localhost:8080',
        flavor: 'dev',
        turnstileSiteKey: testSiteKey,
      );
      expect(noAddress.appPublicUrl, isNull);
      expect(noAddress.captchaPage, isNull);
    });

    test('refuses a malformed site key', () {
      for (final key in ['has space', 'quote"', 'x' * 65]) {
        expect(
          () => web(
            appEnv: 'local',
            page: 'http://localhost:3000/',
            turnstileSiteKey: key,
          ),
          throwsA(isA<EnvException>()),
          reason: key,
        );
      }
    });

    test('APP_PUBLIC_URL follows the origin rules', () {
      for (final (appEnv, flavor, url) in [
        ('production', 'prod', 'http://app.example.com'),
        ('local', 'dev', 'http://localhost:3000/login'),
        ('local', 'dev', 'localhost:3000'),
      ]) {
        expect(
          () => mobile(
            appEnv: appEnv,
            apiBaseUrl: appEnv == 'local'
                ? 'http://localhost:8080'
                : 'https://api.example.com',
            flavor: flavor,
            appPublicUrl: url,
          ),
          throwsA(
            isA<EnvException>().having(
              (e) => e.message,
              'message',
              contains('APP_PUBLIC_URL'),
            ),
          ),
          reason: url,
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
      expect(env.apiRoot, Uri.parse('https://app.example.com/api/v1'));
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
