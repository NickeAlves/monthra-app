// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_api.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dashboardApi)
final dashboardApiProvider = DashboardApiProvider._();

final class DashboardApiProvider
    extends $FunctionalProvider<DashboardApi, DashboardApi, DashboardApi>
    with $Provider<DashboardApi> {
  DashboardApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardApiHash();

  @$internal
  @override
  $ProviderElement<DashboardApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DashboardApi create(Ref ref) {
    return dashboardApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DashboardApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DashboardApi>(value),
    );
  }
}

String _$dashboardApiHash() => r'8414ed7c70edc9da58b2a612993f293e178c5747';
