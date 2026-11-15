import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/core/network/api_problem.dart';
import 'package:monthra/l10n/l10n.dart';

/// What a screen says about a failed call: the app's own sentence for each
/// known problem, never the server's `detail` as it came.
typedef ApiErrorMessage = ({String message, String? reference});

extension ApiErrorText on AppLocalizations {
  /// The sentence for [error], with the request id as the `reference` when
  /// the failure is unexpected (support finds the call in the logs by it).
  ApiErrorMessage apiError(ApiException error) {
    final message = switch (error) {
      ApiProblemException(:final code, :final retryAfter) => switch (code) {
        ProblemCode.invalidCredentials => errorInvalidCredentials,
        ProblemCode.emailNotVerified => authEmailNotVerified,
        ProblemCode.rateLimited =>
          retryAfter == null || retryAfter == Duration.zero
              ? errorRateLimitedSoon
              : errorRateLimited(retryAfter.inSeconds),
        ProblemCode.captchaRequired ||
        ProblemCode.captchaInvalid => errorCaptcha,
        ProblemCode.mfaCodeInvalid => errorMfaCodeInvalid,
        ProblemCode.validationFailed => errorCheckFields,
        ProblemCode.serviceUnavailable ||
        ProblemCode.internalError => errorUnavailable,
        _ => errorGeneric,
      },
      NetworkException() => errorOffline,
      ApiTimeoutException() => errorTimeout,
      UnexpectedApiException(:final status) when (status ?? 0) >= 500 =>
        errorUnavailable,
      UnexpectedApiException() || CancelledException() => errorGeneric,
    };
    final expected = switch (error) {
      ApiProblemException(:final code) =>
        code != null &&
            code != ProblemCode.internalError &&
            message != errorGeneric,
      NetworkException() || ApiTimeoutException() => true,
      _ => false,
    };
    return (message: message, reference: expected ? null : error.requestId);
  }

  /// The sentence for a field error [code] (`errors[].code` of a `422`, or
  /// the app's own check). [min]/[max] are the field's length bounds;
  /// [email] picks the email wording for `invalid`.
  String fieldError(
    FieldCode? code, {
    int? min,
    int? max,
    bool email = false,
  }) => switch (code) {
    FieldCode.required => errorFieldRequired,
    FieldCode.invalid when email => errorEmailInvalid,
    FieldCode.tooShort when min != null => errorTooShort(min),
    FieldCode.tooLong when max != null => errorTooLong(max),
    FieldCode.breached => errorPasswordBreached,
    _ => errorFieldInvalid,
  };
}
