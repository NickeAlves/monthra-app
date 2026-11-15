import 'package:freezed_annotation/freezed_annotation.dart';

part 'csrf_token.freezed.dart';
part 'csrf_token.g.dart';

/// `GET /auth/csrf`: the token a browser sends back in `X-CSRF-Token` (the
/// same value as the non-`HttpOnly` CSRF cookie).
@freezed
abstract class CsrfToken with _$CsrfToken {
  const factory({required String csrfToken}) = _CsrfToken;

  factory fromJson(Map<String, Object?> json) => _$CsrfTokenFromJson(json);
}
