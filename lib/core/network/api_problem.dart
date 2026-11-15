import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_problem.freezed.dart';
part 'api_problem.g.dart';

/// An API error (RFC 7807, `application/problem+json`): [title] and
/// [detail] come translated by `Accept-Language` or the user's language,
/// [code] is stable and is what the app branches on.
@freezed
abstract class ApiProblem with _$ApiProblem {
  const factory({
    required String type,
    required String title,
    required int status,
    required String code,
    String? detail,
    String? instance,
    String? requestId,
    @Default(<FieldError>[]) List<FieldError> errors,
  }) = _ApiProblem;

  const new _();

  factory fromJson(Map<String, Object?> json) => _$ApiProblemFromJson(json);

  /// [code] as a known value; null for a code newer than this app.
  ProblemCode? get knownCode => ProblemCode.fromWire(code);

  /// The error codes of [field] (`name`, `card.closingDay`, ...).
  List<String> codesOf(String field) => [
    for (final e in errors)
      if (e.field == field) e.code,
  ];
}

/// One rejected field of a `422 validation_failed`.
@freezed
abstract class FieldError with _$FieldError {
  const factory({required String field, required String code}) = _FieldError;

  const new _();

  factory fromJson(Map<String, Object?> json) => _$FieldErrorFromJson(json);

  /// [code] as a known value; null for a code newer than this app.
  FieldCode? get knownCode => FieldCode.fromWire(code);
}

/// The server's problem codes: the `Problem.code` enum of
/// monthra-server/docs/openapi.yaml.
enum ProblemCode {
  badRequest('bad_request'),
  notFound('not_found'),
  methodNotAllowed('method_not_allowed'),
  payloadTooLarge('payload_too_large'),
  internalError('internal_error'),
  serviceUnavailable('service_unavailable'),
  rateLimited('rate_limited'),
  originNotAllowed('origin_not_allowed'),
  csrfInvalid('csrf_invalid'),
  ambiguousCredentials('ambiguous_credentials'),
  unsupportedMediaType('unsupported_media_type'),
  validationFailed('validation_failed'),
  unauthorized('unauthorized'),
  invalidCredentials('invalid_credentials'),
  emailNotVerified('email_not_verified'),
  tokenInvalid('token_invalid'),
  refreshConflict('refresh_conflict'),
  captchaRequired('captcha_required'),
  captchaInvalid('captcha_invalid'),
  passwordIncorrect('password_incorrect'),
  mfaCodeInvalid('mfa_code_invalid'),
  mfaChallengeInvalid('mfa_challenge_invalid'),
  mfaAlreadyEnabled('mfa_already_enabled'),
  mfaNotEnabled('mfa_not_enabled'),
  mfaSetupRequired('mfa_setup_required'),
  limitReached('limit_reached'),
  accountInUse('account_in_use'),
  categoryInUse('category_in_use'),
  usedByRecurrence('used_by_recurrence'),
  budgetExists('budget_exists'),
  exceedsPosition('exceeds_position');

  new(this.wire);

  /// The value on the wire.
  final String wire;

  static final Map<String, ProblemCode> _byWire = {
    for (final c in values) c.wire: c,
  };

  static ProblemCode? fromWire(String? wire) => _byWire[wire];
}

/// The codes of a field error (`errors[].code`): the server's
/// `domain.FieldCode` values.
enum FieldCode {
  required('required'),
  invalid('invalid'),
  tooShort('too_short'),
  tooLong('too_long'),
  breached('breached'),
  outOfRange('out_of_range'),
  archived('archived'),
  kindMismatch('kind_mismatch'),
  currencyMismatch('currency_mismatch'),
  exceedsPosition('exceeds_position');

  new(this.wire);

  /// The value on the wire.
  final String wire;

  static final Map<String, FieldCode> _byWire = {
    for (final c in values) c.wire: c,
  };

  static FieldCode? fromWire(String? wire) => _byWire[wire];
}
