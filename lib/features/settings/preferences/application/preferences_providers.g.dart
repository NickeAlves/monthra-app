// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The local store, opened in `main` before the first frame and passed in
/// with `preferencesStoreProvider.overrideWithValue`.

@ProviderFor(preferencesStore)
final preferencesStoreProvider = PreferencesStoreProvider._();

/// The local store, opened in `main` before the first frame and passed in
/// with `preferencesStoreProvider.overrideWithValue`.

final class PreferencesStoreProvider
    extends
        $FunctionalProvider<
          PreferencesStore,
          PreferencesStore,
          PreferencesStore
        >
    with $Provider<PreferencesStore> {
  /// The local store, opened in `main` before the first frame and passed in
  /// with `preferencesStoreProvider.overrideWithValue`.
  PreferencesStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'preferencesStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$preferencesStoreHash();

  @$internal
  @override
  $ProviderElement<PreferencesStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PreferencesStore create(Ref ref) {
    return preferencesStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PreferencesStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PreferencesStore>(value),
    );
  }
}

String _$preferencesStoreHash() => r'308315b84a6c0a72b3e5087774750ecb11de34df';

/// The preferences the root widget applies (§7.6): theme and language.
///
/// Changes apply at once and are saved locally. The profile sync
/// (`PATCH /me/preferences`) and "the server's value wins at sign-in"
/// ([replaceAll]) come with the API client and the settings screen.

@ProviderFor(Preferences)
final preferencesProvider = PreferencesProvider._();

/// The preferences the root widget applies (§7.6): theme and language.
///
/// Changes apply at once and are saved locally. The profile sync
/// (`PATCH /me/preferences`) and "the server's value wins at sign-in"
/// ([replaceAll]) come with the API client and the settings screen.
final class PreferencesProvider
    extends $NotifierProvider<Preferences, AppPreferences> {
  /// The preferences the root widget applies (§7.6): theme and language.
  ///
  /// Changes apply at once and are saved locally. The profile sync
  /// (`PATCH /me/preferences`) and "the server's value wins at sign-in"
  /// ([replaceAll]) come with the API client and the settings screen.
  PreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'preferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$preferencesHash();

  @$internal
  @override
  Preferences create() => Preferences();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppPreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppPreferences>(value),
    );
  }
}

String _$preferencesHash() => r'56e248a693795bf8088202d75c14396342238604';

/// The preferences the root widget applies (§7.6): theme and language.
///
/// Changes apply at once and are saved locally. The profile sync
/// (`PATCH /me/preferences`) and "the server's value wins at sign-in"
/// ([replaceAll]) come with the API client and the settings screen.

abstract class _$Preferences extends $Notifier<AppPreferences> {
  AppPreferences build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AppPreferences, AppPreferences>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppPreferences, AppPreferences>,
              AppPreferences,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The device's languages in the user's order, kept current while the app
/// runs (the system language can change with the app open).

@ProviderFor(DeviceLocales)
final deviceLocalesProvider = DeviceLocalesProvider._();

/// The device's languages in the user's order, kept current while the app
/// runs (the system language can change with the app open).
final class DeviceLocalesProvider
    extends $NotifierProvider<DeviceLocales, List<Locale>> {
  /// The device's languages in the user's order, kept current while the app
  /// runs (the system language can change with the app open).
  DeviceLocalesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceLocalesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceLocalesHash();

  @$internal
  @override
  DeviceLocales create() => DeviceLocales();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Locale> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Locale>>(value),
    );
  }
}

String _$deviceLocalesHash() => r'f33a7a1926920de6d70f76fc229542cc29b433bc';

/// The device's languages in the user's order, kept current while the app
/// runs (the system language can change with the app open).

abstract class _$DeviceLocales extends $Notifier<List<Locale>> {
  List<Locale> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<Locale>, List<Locale>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Locale>, List<Locale>>,
              List<Locale>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The language the app speaks now: the chosen one, else the device's
/// best match ([AppLocale.resolve]). The one source for the UI locale and,
/// with the API client, the `Accept-Language` header.

@ProviderFor(appLocale)
final appLocaleProvider = AppLocaleProvider._();

/// The language the app speaks now: the chosen one, else the device's
/// best match ([AppLocale.resolve]). The one source for the UI locale and,
/// with the API client, the `Accept-Language` header.

final class AppLocaleProvider
    extends $FunctionalProvider<AppLocale, AppLocale, AppLocale>
    with $Provider<AppLocale> {
  /// The language the app speaks now: the chosen one, else the device's
  /// best match ([AppLocale.resolve]). The one source for the UI locale and,
  /// with the API client, the `Accept-Language` header.
  AppLocaleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appLocaleProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appLocaleHash();

  @$internal
  @override
  $ProviderElement<AppLocale> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppLocale create(Ref ref) {
    return appLocale(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppLocale value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppLocale>(value),
    );
  }
}

String _$appLocaleHash() => r'811fef9570b08ddf223f9f995029ea8844d5cfbf';
