import 'package:dio/dio.dart';

/// Sends the UI language as `Accept-Language` (§7.6), read on every call so
/// a switch applies to the next request. The server picks problem titles
/// and emails by it before sign-in; afterwards the profile's language wins.
class LocaleInterceptor extends Interceptor {
  new(this._languageTag);

  final String Function() _languageTag;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['accept-language'] = _languageTag();
    handler.next(options);
  }
}
