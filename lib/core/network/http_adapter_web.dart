import 'package:dio/browser.dart';
import 'package:dio/dio.dart';

/// The browser's client (see `http_adapter.dart`). The API is on the page's
/// own origin, where the browser sends the session cookies by itself;
/// `withCredentials` (§7.1) keeps them on a same-site API host too.
HttpClientAdapter createHttpAdapter() =>
    BrowserHttpClientAdapter(withCredentials: true);
