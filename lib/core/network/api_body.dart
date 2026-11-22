import 'package:monthra/core/network/api_exception.dart';

/// [body] read by [fromJson]; an empty body or one the app cannot read is an
/// [UnexpectedApiException], like any other surprise from the API.
T readJson<T>(
  Map<String, Object?>? body,
  T Function(Map<String, Object?>) fromJson,
) {
  if (body == null) {
    throw const UnexpectedApiException(status: 200, cause: 'an empty body');
  }
  try {
    return fromJson(body);
  } on Object catch (e) {
    throw UnexpectedApiException(status: 200, cause: e);
  }
}
