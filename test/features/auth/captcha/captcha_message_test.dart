import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/features/auth/captcha/captcha_message.dart';

Map<String, Object?> page(
  String type, [
  Map<String, Object?> extra = const {},
]) => {'source': 'monthra-turnstile', 'type': type, ...extra};

void main() {
  group('CaptchaMessage.parse', () {
    test('reads every message of the page, as a map or as JSON', () {
      final messages = {
        page('ready'): const CaptchaReady(),
        page('token', {'token': 'abc.def'}): const CaptchaSolved('abc.def'),
        page('expired'): const CaptchaExpired(),
        page('error', {'code': '110200'}): const CaptchaFailed('110200'),
        page('unsupported'): const CaptchaUnsupported(),
      };
      for (final MapEntry(key: data, value: message) in messages.entries) {
        expect(CaptchaMessage.parse(data), message, reason: '$data');
        expect(CaptchaMessage.parse(jsonEncode(data)), message);
      }
    });

    test('drops whatever is not a message of the page', () {
      for (final data in <Object?>[
        null,
        42,
        'not json',
        '[]',
        {'type': 'token', 'token': 'abc'},
        {'source': 'other', 'type': 'token', 'token': 'abc'},
        page('unknown'),
        page('token'),
        page('token', {'token': ''}),
        page('token', {'token': 7}),
        page('token', {'token': 'a' * 2049}),
        'x' * 5000,
      ]) {
        expect(CaptchaMessage.parse(data), isNull, reason: '$data');
      }
    });

    test('keeps a token of the longest size Turnstile issues', () {
      final token = 'a' * CaptchaMessage.maxTokenLength;
      expect(
        CaptchaMessage.parse(page('token', {'token': token})),
        CaptchaSolved(token),
      );
    });

    test('an odd error code reads as unknown', () {
      for (final code in [null, '', 'has space', 'x' * 33, 12]) {
        expect(
          CaptchaMessage.parse(page('error', {'code': code})),
          const CaptchaFailed('unknown'),
          reason: '$code',
        );
      }
    });

    test('never prints a token', () {
      expect('${const CaptchaSolved('secret')}', isNot(contains('secret')));
    });
  });
}
