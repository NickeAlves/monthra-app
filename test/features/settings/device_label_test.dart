import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/features/settings/domain/device_label.dart';

void main() {
  const cases = {
    'Monthra (iOS)': (browser: null, os: 'iOS', app: true),
    'Monthra (Android)': (browser: null, os: 'Android', app: true),
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36': (
      browser: 'Chrome',
      os: 'macOS',
      app: false,
    ),
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 '
        '(KHTML, like Gecko) Version/19.1 Safari/605.1.15': (
      browser: 'Safari',
      os: 'macOS',
      app: false,
    ),
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, '
        'like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0': (
      browser: 'Edge',
      os: 'Windows',
      app: false,
    ),
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 '
        'Firefox/145.0': (
      browser: 'Firefox',
      os: 'Windows',
      app: false,
    ),
    'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) '
        'Chrome/142.0.0.0 Safari/537.36 OPR/125.0.0.0': (
      browser: 'Opera',
      os: 'Linux',
      app: false,
    ),
    'Mozilla/5.0 (iPhone; CPU iPhone OS 19_1 like Mac OS X) '
        'AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/142.0.0.0 '
        'Mobile/15E148 Safari/604.1': (
      browser: 'Chrome',
      os: 'iOS',
      app: false,
    ),
    'Mozilla/5.0 (iPad; CPU OS 19_1 like Mac OS X) AppleWebKit/605.1.15 '
        '(KHTML, like Gecko) Version/19.1 Mobile/15E148 Safari/604.1': (
      browser: 'Safari',
      os: 'iPadOS',
      app: false,
    ),
    'Mozilla/5.0 (Linux; Android 16; SM-S931B) AppleWebKit/537.36 (KHTML, '
        'like Gecko) SamsungBrowser/29.0 Chrome/136.0.0.0 Mobile '
        'Safari/537.36': (
      browser: 'Samsung Internet',
      os: 'Android',
      app: false,
    ),
    'Mozilla/5.0 (X11; CrOS x86_64 16433.0.0) AppleWebKit/537.36 (KHTML, '
        'like Gecko) Chrome/142.0.0.0 Safari/537.36': (
      browser: 'Chrome',
      os: 'ChromeOS',
      app: false,
    ),
    'Dart/3.13 (dart:io)': (browser: null, os: null, app: false),
    'curl/8.7.1': (browser: null, os: null, app: false),
    '': (browser: null, os: null, app: false),
  };
  for (final MapEntry(key: ua, value: want) in cases.entries) {
    test('reads "${ua.length > 40 ? '${ua.substring(0, 40)}...' : ua}"', () {
      expect(describeUserAgent(ua), want);
    });
  }
}
