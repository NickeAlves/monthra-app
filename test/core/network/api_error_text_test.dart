import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/network/api_error_text.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/core/network/api_problem.dart';
import 'package:monthra/l10n/l10n.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));

  ApiProblemException problem(int status, String code, {Duration? wait}) =>
      ApiProblemException(
        ApiProblem(
          type: 'urn:monthra:problem:$code',
          title: 'Server title',
          detail: 'Server detail',
          status: status,
          code: code,
        ),
        retryAfter: wait,
        requestId: 'req-1',
      );

  test('known problems get their sentence and no reference', () {
    expect(en.apiError(problem(401, 'invalid_credentials')), (
      message: en.errorInvalidCredentials,
      reference: null,
    ));
    expect(
      en.apiError(
        problem(429, 'rate_limited', wait: const Duration(seconds: 30)),
      ),
      (message: en.errorRateLimited(30), reference: null),
    );
    expect(
      en.apiError(problem(429, 'rate_limited')).message,
      en.errorRateLimitedSoon,
    );
    expect(
      en.apiError(problem(403, 'captcha_required')).message,
      en.errorCaptcha,
    );
    expect(
      en.apiError(problem(403, 'captcha_invalid')).message,
      en.errorCaptcha,
    );
    expect(en.apiError(const NetworkException(requestId: 'req-1')), (
      message: en.errorOffline,
      reference: null,
    ));
  });

  test('the unexpected ones quote the request id, never the server text', () {
    for (final error in <ApiException>[
      problem(500, 'internal_error'),
      problem(403, 'csrf_invalid'),
      problem(418, 'a_code_from_the_future'),
      const UnexpectedApiException(status: 502, requestId: 'req-1'),
    ]) {
      final text = en.apiError(error);
      expect(text.reference, 'req-1', reason: '$error');
      expect(text.message, isNot(contains('Server')));
    }
  });

  test('field errors', () {
    expect(en.fieldError(FieldCode.required), en.errorFieldRequired);
    expect(en.fieldError(FieldCode.invalid, email: true), en.errorEmailInvalid);
    expect(en.fieldError(FieldCode.invalid), en.errorFieldInvalid);
    expect(en.fieldError(FieldCode.tooShort, min: 10), en.errorTooShort(10));
    expect(en.fieldError(FieldCode.tooLong, max: 100), en.errorTooLong(100));
    expect(en.fieldError(FieldCode.breached), en.errorPasswordBreached);
    expect(en.fieldError(null), en.errorFieldInvalid);
  });
}
