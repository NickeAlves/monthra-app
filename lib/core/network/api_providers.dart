import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:monthra/core/config/env_provider.dart';
import 'package:monthra/core/network/api_client.dart';
import 'package:monthra/core/network/http_adapter.dart';
import 'package:monthra/core/network/session_refresher.dart';
import 'package:monthra/core/security/token_store.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_providers.g.dart';

/// The language tag the API answers in (`Accept-Language`). `main` points
/// it at the UI language (`appLocaleProvider`, see `appOverrides`): core
/// never imports a feature.
@Riverpod(keepAlive: true)
String apiLanguage(Ref ref) => throw StateError(
  'apiLanguageProvider is overridden in main (appOverrides)',
);

/// Cookies on the web, Bearer tokens on Android and iOS (§6.2).
@Riverpod(keepAlive: true)
SessionMode sessionMode(Ref ref) =>
    kIsWeb ? SessionMode.cookie : SessionMode.bearer;

/// The saved native session; nothing on the web.
@Riverpod(keepAlive: true)
TokenStore tokenStore(Ref ref) => switch (ref.watch(sessionModeProvider)) {
  SessionMode.cookie => const NoTokenStore(),
  SessionMode.bearer => SecureTokenStore(),
};

/// What the client tells the app about the session ([SessionEvent]): the
/// auth flow listens to send the user to sign-in.
@Riverpod(keepAlive: true)
SessionEvents sessionEvents(Ref ref) {
  final events = SessionEvents();
  ref.onDispose(events.close);
  return events;
}

/// How requests leave the app ([createHttpAdapter]); tests answer them with
/// a fake.
@Riverpod(keepAlive: true)
HttpClientAdapter httpAdapter(Ref ref) => createHttpAdapter();

/// The configured `Dio` ([createApiDio]); features use [apiClientProvider].
@Riverpod(keepAlive: true)
Dio apiDio(Ref ref) {
  final env = ref.watch(envProvider);
  final events = ref.watch(sessionEventsProvider);
  final dio = createApiDio(
    apiRoot: env.apiRoot,
    mode: ref.watch(sessionModeProvider),
    tokens: ref.watch(tokenStoreProvider),
    // Read per request: a language switch applies to the next call.
    languageTag: () => ref.read(apiLanguageProvider),
    onSessionEvent: events.add,
    adapter: ref.watch(httpAdapterProvider),
    log: kDebugMode ? debugPrint : null,
  );
  ref.onDispose(dio.close);
  return dio;
}

@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) => ApiClient(ref.watch(apiDioProvider));

/// A broadcast of [SessionEvent]s.
class SessionEvents {
  final _controller = StreamController<SessionEvent>.broadcast();

  Stream<SessionEvent> get stream => _controller.stream;

  void add(SessionEvent event) {
    if (!_controller.isClosed) _controller.add(event);
  }

  Future<void> close() => _controller.close();
}
