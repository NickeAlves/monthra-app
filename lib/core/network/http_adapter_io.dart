import 'package:dio/dio.dart';
import 'package:dio/io.dart';

/// dart:io's client (see `http_adapter.dart`). Certificate pinning, when it
/// comes (§6.8), hooks in here.
HttpClientAdapter createHttpAdapter() => IOHttpClientAdapter();
