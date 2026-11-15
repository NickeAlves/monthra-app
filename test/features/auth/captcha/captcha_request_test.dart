import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/features/auth/captcha/captcha_request.dart';

void main() {
  final page = Uri.parse('https://app.example.com/turnstile.html');

  CaptchaRequest request({
    CaptchaSize size = CaptchaSize.flexible,
    Color background = const Color(0xFFF5F5F3),
  }) => CaptchaRequest(
    page: page,
    siteKey: '0x4AAA_b-c',
    action: CaptchaAction.register,
    brightness: Brightness.dark,
    languageTag: 'pt-BR',
    size: size,
    background: background,
  );

  test('the page address carries every setting turnstile.js reads', () {
    expect(
      request().url,
      Uri.parse(
        'https://app.example.com/turnstile.html?sitekey=0x4AAA_b-c'
        '&action=register&theme=dark&lang=pt-BR&size=flexible&bg=F5F5F3',
      ),
    );
    expect(
      request(background: const Color(0x80010203)).url.queryParameters['bg'],
      '010203',
      reason: 'six hex digits, without the alpha',
    );
  });

  test('requests compare by their address', () {
    expect(request(), request());
    expect(request().hashCode, request().hashCode);
    expect(request(), isNot(request(size: CaptchaSize.compact)));
  });

  test('the widget is flexible from 300 px, compact below', () {
    expect(CaptchaSize.forWidth(400), CaptchaSize.flexible);
    expect(CaptchaSize.forWidth(300), CaptchaSize.flexible);
    expect(CaptchaSize.forWidth(299), CaptchaSize.compact);
    expect(CaptchaSize.flexible.height, 65);
    expect(CaptchaSize.compact.height, 140);
  });

  group('allowCaptchaNavigation', () {
    bool allow(String target, {bool main = true}) =>
        allowCaptchaNavigation(page, target, isMainFrame: main);

    test('the main frame shows the captcha page only', () {
      expect(allow('${request().url}'), isTrue);
      expect(allow('https://app.example.com/turnstile.html'), isTrue);
      for (final target in [
        'https://app.example.com/',
        'https://app.example.com/login',
        'http://app.example.com/turnstile.html',
        'https://app.example.com:8443/turnstile.html',
        'https://evil.example/turnstile.html',
        'https://user@app.example.com/turnstile.html',
        'https://www.cloudflare.com/privacypolicy/',
        'https://challenges.cloudflare.com/',
        'javascript:alert(1)',
        'about:blank',
      ]) {
        expect(allow(target), isFalse, reason: target);
      }
    });

    test("frames hold Cloudflare's challenge only", () {
      for (final target in [
        'https://challenges.cloudflare.com/cdn-cgi/challenge-platform/h/b/x',
        'about:blank',
        'about:srcdoc',
      ]) {
        expect(allow(target, main: false), isTrue, reason: target);
      }
      for (final target in [
        'http://challenges.cloudflare.com/',
        'https://challenges.cloudflare.com.evil.example/',
        'https://www.cloudflare.com/',
        'https://app.example.com/turnstile.html',
        'data:text/html,<p>',
      ]) {
        expect(allow(target, main: false), isFalse, reason: target);
      }
    });
  });
}
