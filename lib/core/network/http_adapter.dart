/// The HTTP adapter of this platform: dart:io on Android and iOS, the
/// browser's XMLHttpRequest on the web.
library;

export 'http_adapter_io.dart'
    if (dart.library.js_interop) 'http_adapter_web.dart';
