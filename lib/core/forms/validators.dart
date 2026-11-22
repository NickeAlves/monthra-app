import 'package:monthra/core/network/api_error_text.dart';
import 'package:monthra/core/network/api_problem.dart';
import 'package:monthra/l10n/l10n.dart';

/// The server's bounds (monthra-server `internal/domain/user.go`), checked
/// before sending so most mistakes never cost a request. The server stays
/// the judge: its `422` field errors show under the same fields.
abstract final class AuthLimits {
  static const int emailMax = 254;
  static const int nameMax = 100;
  static const int passwordMin = 10;
  static const int passwordMax = 1024;
  static const int mfaCodeLength = 6;
}

/// Field checks of the account forms (sign-in, sign-up, settings),
/// returning the sentence to show.
extension AuthValidators on AppLocalizations {
  String? validateEmail(String value) {
    final email = value.trim();
    if (email.isEmpty) return fieldError(FieldCode.required);
    if (email.length > AuthLimits.emailMax) {
      return fieldError(FieldCode.tooLong, max: AuthLimits.emailMax);
    }
    final at = email.indexOf('@');
    final valid =
        at > 0 &&
        at == email.lastIndexOf('@') &&
        email.indexOf('.', at) > at + 1 &&
        !email.endsWith('.') &&
        !email.contains(RegExp(r'\s'));
    return valid ? null : fieldError(FieldCode.invalid, email: true);
  }

  String? validateRequired(String value) =>
      value.trim().isEmpty ? fieldError(FieldCode.required) : null;

  /// A password being typed to sign in: only that there is one.
  String? validateCurrentPassword(String value) =>
      value.isEmpty ? fieldError(FieldCode.required) : null;

  /// A new password (sign-up, reset): the server's length policy, counted in
  /// characters as the server does.
  String? validateNewPassword(String value) {
    final length = value.runes.length;
    if (length == 0) return fieldError(FieldCode.required);
    if (length < AuthLimits.passwordMin) {
      return fieldError(FieldCode.tooShort, min: AuthLimits.passwordMin);
    }
    if (length > AuthLimits.passwordMax) {
      return fieldError(FieldCode.tooLong, max: AuthLimits.passwordMax);
    }
    return null;
  }

  String? validateName(String value) {
    final name = value.trim();
    if (name.isEmpty) return fieldError(FieldCode.required);
    if (name.runes.length > AuthLimits.nameMax) {
      return fieldError(FieldCode.tooLong, max: AuthLimits.nameMax);
    }
    return null;
  }

  /// The sentence for the first error the server gave [field], if any.
  String? serverFieldError(
    ApiProblem? problem,
    String field, {
    int? min,
    int? max,
    bool email = false,
  }) {
    final codes = problem?.codesOf(field) ?? const [];
    if (codes.isEmpty) return null;
    return fieldError(
      FieldCode.fromWire(codes.first),
      min: min,
      max: max,
      email: email,
    );
  }
}
