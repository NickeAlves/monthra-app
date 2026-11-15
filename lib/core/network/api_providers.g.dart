// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The language tag the API answers in (`Accept-Language`). `main` points
/// it at the UI language (`appLocaleProvider`, see `appOverrides`): core
/// never imports a feature.

@ProviderFor(apiLanguage)
final apiLanguageProvider = ApiLanguageProvider._();

/// The language tag the API answers in (`Accept-Language`). `main` points
/// it at the UI language (`appLocaleProvider`, see `appOverrides`): core
/// never imports a feature.

final class ApiLanguageProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// The language tag the API answers in (`Accept-Language`). `main` points
  /// it at the UI language (`appLocaleProvider`, see `appOverrides`): core
  /// never imports a feature.
  ApiLanguageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'apiLanguageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$apiLanguageHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return apiLanguage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$apiLanguageHash() => r'4eede5f30f999d81d27ce75609b823f9eb515b27';

/// Cookies on the web, Bearer tokens on Android and iOS (§6.2).

@ProviderFor(sessionMode)
final sessionModeProvider = SessionModeProvider._();

/// Cookies on the web, Bearer tokens on Android and iOS (§6.2).

final class SessionModeProvider
    extends $FunctionalProvider<SessionMode, SessionMode, SessionMode>
    with $Provider<SessionMode> {
  /// Cookies on the web, Bearer tokens on Android and iOS (§6.2).
  SessionModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionModeHash();

  @$internal
  @override
  $ProviderElement<SessionMode> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SessionMode create(Ref ref) {
    return sessionMode(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionMode>(value),
    );
  }
}

String _$sessionModeHash() => r'a54515b616b83982719cef8e7247ffbccf854c08';

/// The saved native session; nothing on the web.

@ProviderFor(tokenStore)
final tokenStoreProvider = TokenStoreProvider._();

/// The saved native session; nothing on the web.

final class TokenStoreProvider
    extends $FunctionalProvider<TokenStore, TokenStore, TokenStore>
    with $Provider<TokenStore> {
  /// The saved native session; nothing on the web.
  TokenStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tokenStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tokenStoreHash();

  @$internal
  @override
  $ProviderElement<TokenStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TokenStore create(Ref ref) {
    return tokenStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TokenStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TokenStore>(value),
    );
  }
}

String _$tokenStoreHash() => r'f61e25110aedda50fc1c893f1c63a312622ccbfc';

/// What the client tells the app about the session ([SessionEvent]): the
/// auth flow listens to send the user to sign-in.

@ProviderFor(sessionEvents)
final sessionEventsProvider = SessionEventsProvider._();

/// What the client tells the app about the session ([SessionEvent]): the
/// auth flow listens to send the user to sign-in.

final class SessionEventsProvider
    extends $FunctionalProvider<SessionEvents, SessionEvents, SessionEvents>
    with $Provider<SessionEvents> {
  /// What the client tells the app about the session ([SessionEvent]): the
  /// auth flow listens to send the user to sign-in.
  SessionEventsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionEventsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionEventsHash();

  @$internal
  @override
  $ProviderElement<SessionEvents> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SessionEvents create(Ref ref) {
    return sessionEvents(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionEvents value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionEvents>(value),
    );
  }
}

String _$sessionEventsHash() => r'3b5ada90aa272d7c927f2316dd71344b7f34bfc7';

/// How requests leave the app ([createHttpAdapter]); tests answer them with
/// a fake.

@ProviderFor(httpAdapter)
final httpAdapterProvider = HttpAdapterProvider._();

/// How requests leave the app ([createHttpAdapter]); tests answer them with
/// a fake.

final class HttpAdapterProvider
    extends
        $FunctionalProvider<
          HttpClientAdapter,
          HttpClientAdapter,
          HttpClientAdapter
        >
    with $Provider<HttpClientAdapter> {
  /// How requests leave the app ([createHttpAdapter]); tests answer them with
  /// a fake.
  HttpAdapterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'httpAdapterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$httpAdapterHash();

  @$internal
  @override
  $ProviderElement<HttpClientAdapter> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HttpClientAdapter create(Ref ref) {
    return httpAdapter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HttpClientAdapter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HttpClientAdapter>(value),
    );
  }
}

String _$httpAdapterHash() => r'bb2641424f605e0ea695c39287ecb0f20ef9eab6';

/// The configured `Dio` ([createApiDio]); features use [apiClientProvider].

@ProviderFor(apiDio)
final apiDioProvider = ApiDioProvider._();

/// The configured `Dio` ([createApiDio]); features use [apiClientProvider].

final class ApiDioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// The configured `Dio` ([createApiDio]); features use [apiClientProvider].
  ApiDioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'apiDioProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$apiDioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return apiDio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$apiDioHash() => r'44f0adf9e91981dde85e0fb2bf14e78d44657dfc';

@ProviderFor(apiClient)
final apiClientProvider = ApiClientProvider._();

final class ApiClientProvider
    extends $FunctionalProvider<ApiClient, ApiClient, ApiClient>
    with $Provider<ApiClient> {
  ApiClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'apiClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$apiClientHash();

  @$internal
  @override
  $ProviderElement<ApiClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ApiClient create(Ref ref) {
    return apiClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ApiClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ApiClient>(value),
    );
  }
}

String _$apiClientHash() => r'11a9526098eef9ce392e150c167f9fa613544c08';
