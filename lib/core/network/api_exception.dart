import 'package:dio/dio.dart';
import 'package:monthra/core/network/api_problem.dart';

/// Why an API call failed. `ApiClient` throws only these, so features never
/// see dio's types.
sealed class ApiException implements Exception {
  const new({this.requestId});

  /// Turns a failed dio call into an [ApiException].
  factory from(DioException e) {
    final requestId = _requestIdOf(e);
    return switch (e.type) {
      DioExceptionType.cancel => CancelledException(requestId: requestId),
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.transformTimeout => ApiTimeoutException(
        requestId: requestId,
      ),
      DioExceptionType.connectionError ||
      DioExceptionType.badCertificate => NetworkException(requestId: requestId),
      DioExceptionType.badResponse ||
      DioExceptionType.unknown => _fromResponse(e, requestId),
    };
  }

  /// The `X-Request-ID` of the call: quote it when reporting a problem.
  final String? requestId;

  static ApiException _fromResponse(DioException e, String? requestId) {
    final response = e.response;
    if (response == null) {
      // A failure inside the client (an interceptor, a decoder).
      return UnexpectedApiException(cause: e.error, requestId: requestId);
    }
    final problem = problemOf(response);
    if (problem != null) {
      return ApiProblemException(
        problem,
        retryAfter: retryAfterOf(response),
        requestId: problem.requestId ?? requestId,
      );
    }
    return UnexpectedApiException(
      status: response.statusCode,
      cause: e.error,
      requestId: requestId,
    );
  }

  static String? _requestIdOf(DioException e) =>
      e.response?.headers.value(requestIdHeader) ??
      e.requestOptions.headers[requestIdHeader] as String?;
}

/// The API answered with a problem (`application/problem+json`).
final class ApiProblemException extends ApiException {
  const new(this.problem, {this.retryAfter, super.requestId});

  final ApiProblem problem;

  /// `Retry-After` of a `429` or `503`.
  final Duration? retryAfter;

  int get status => problem.status;

  ProblemCode? get code => problem.knownCode;

  @override
  String toString() =>
      'ApiProblemException(${problem.status} ${problem.code}, '
      'requestId: $requestId)';
}

/// The API could not be reached (offline, DNS, refused, TLS).
final class NetworkException extends ApiException {
  const new({super.requestId});

  @override
  String toString() => 'NetworkException(requestId: $requestId)';
}

/// The API took too long to connect or to answer.
final class ApiTimeoutException extends ApiException {
  const new({super.requestId});

  @override
  String toString() => 'ApiTimeoutException(requestId: $requestId)';
}

/// The caller cancelled the call (`CancelToken`).
final class CancelledException extends ApiException {
  const new({super.requestId});

  @override
  String toString() => 'CancelledException(requestId: $requestId)';
}

/// Anything else: an error answer without a problem body (a proxy's 502
/// page, say), a body the app cannot read, or a failure inside the client.
final class UnexpectedApiException extends ApiException {
  const new({this.status, this.cause, super.requestId});

  /// The HTTP status, when there was an answer.
  final int? status;

  /// The underlying error, for the logs.
  final Object? cause;

  @override
  String toString() =>
      'UnexpectedApiException($status, requestId: $requestId, cause: $cause)';
}

/// The header the server echoes (and accepts from a client) to tie a call
/// to its logs.
const requestIdHeader = 'x-request-id';

/// The problem in [response], or null when its body is not one.
ApiProblem? problemOf(Response<Object?>? response) {
  final data = response?.data;
  if (data is! Map<String, Object?>) return null;
  try {
    return ApiProblem.fromJson(data);
  } on Object {
    // CheckedFromJsonException or a type error: not a problem body.
    return null;
  }
}

/// The problem code of a failed call, if its body is a problem.
String? problemCodeOf(DioException e) => problemOf(e.response)?.code;

/// `Retry-After` in seconds (the server never sends an HTTP date).
Duration? retryAfterOf(Response<Object?>? response) {
  final raw = response?.headers.value('retry-after');
  final seconds = raw == null ? null : int.tryParse(raw.trim());
  return seconds == null || seconds < 0 ? null : Duration(seconds: seconds);
}
