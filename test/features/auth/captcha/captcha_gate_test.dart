import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/core/network/api_problem.dart';
import 'package:monthra/features/auth/captcha/captcha_gate.dart';
import 'package:monthra/features/auth/captcha/captcha_message.dart';

ApiProblemException problem(int status, String code) => ApiProblemException(
  ApiProblem.fromJson({
    'type': 'about:blank',
    'title': code,
    'status': status,
    'code': code,
  }),
);

void main() {
  late CaptchaGate gate;
  late int changes;

  setUp(() {
    gate = CaptchaGate(available: true);
    changes = 0;
    gate.addListener(() => changes++);
  });

  test('stays out of the way until the server asks', () {
    expect(gate.needed, isFalse);
    expect(gate.waitingForToken, isFalse);
    expect(gate.take(), isNull);
    expect(gate.onError(problem(401, 'invalid_credentials')), isFalse);
    expect(gate.needed, isFalse);
    expect(changes, 0);
  });

  test('a captcha request shows the widget and resends once it passes', () {
    expect(gate.onError(problem(403, 'captcha_required')), isTrue);
    expect(gate.needed, isTrue);
    expect(gate.waitingForToken, isTrue);
    expect(gate.status, CaptchaStatus.loading);
    final first = gate.attempt;

    expect(gate.onMessage(const CaptchaReady()), isFalse);
    expect(gate.status, CaptchaStatus.ready);
    expect(gate.onMessage(const CaptchaSolved('t1')), isTrue);
    expect(gate.status, CaptchaStatus.solved);
    expect(gate.waitingForToken, isFalse);

    expect(gate.take(), 't1');
    expect(gate.attempt, first + 1, reason: 'a token works once');
    expect(gate.waitingForToken, isTrue);
    expect(gate.status, CaptchaStatus.loading);

    gate.onMessage(const CaptchaReady());
    expect(
      gate.onMessage(const CaptchaSolved('t2')),
      isFalse,
      reason: 'only the refused attempt is sent again by itself',
    );
    expect(changes, greaterThan(0));
  });

  test('a refused token starts a new widget and waits for the person', () {
    gate
      ..onError(problem(403, 'captcha_required'))
      ..onMessage(const CaptchaSolved('t1'));
    final token = gate.take();
    final attempt = gate.attempt;

    expect(token, 't1');
    expect(gate.onError(problem(403, 'captcha_invalid')), isTrue);
    expect(gate.attempt, attempt + 1);
    expect(
      gate.onMessage(const CaptchaSolved('t2')),
      isFalse,
      reason:
          'a server refusing every token would loop with a widget that '
          'passes by itself',
    );
    expect(gate.waitingForToken, isFalse);
  });

  test('an expired token waits for the next one', () {
    gate
      ..onError(problem(403, 'captcha_required'))
      ..onMessage(const CaptchaReady())
      ..onMessage(const CaptchaExpired());
    expect(gate.waitingForToken, isTrue);
    expect(gate.status, CaptchaStatus.ready);
  });

  test('a failure waits for a retry, which loads a new widget', () {
    gate
      ..onError(problem(403, 'captcha_required'))
      ..onMessage(const CaptchaFailed('load'));
    expect(gate.status, CaptchaStatus.failed);
    final attempt = gate.attempt;

    gate.retry();
    expect(gate.status, CaptchaStatus.loading);
    expect(gate.attempt, attempt + 1);
  });

  test('an unsupported browser says so', () {
    gate
      ..onError(problem(403, 'captcha_required'))
      ..onMessage(const CaptchaUnsupported());
    expect(gate.status, CaptchaStatus.unsupported);
    expect(gate.waitingForToken, isTrue);
  });

  test('a build without a captcha page never shows one', () {
    final off = CaptchaGate(available: false);
    expect(off.onError(problem(403, 'captcha_required')), isFalse);
    expect(off.needed, isFalse);
    expect(off.waitingForToken, isFalse);
  });
}
