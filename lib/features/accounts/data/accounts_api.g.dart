// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accounts_api.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(accountsApi)
final accountsApiProvider = AccountsApiProvider._();

final class AccountsApiProvider
    extends $FunctionalProvider<AccountsApi, AccountsApi, AccountsApi>
    with $Provider<AccountsApi> {
  AccountsApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountsApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountsApiHash();

  @$internal
  @override
  $ProviderElement<AccountsApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AccountsApi create(Ref ref) {
    return accountsApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountsApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountsApi>(value),
    );
  }
}

String _$accountsApiHash() => r'98a7baf17251c89ca19e59f0fb566a5f1439d4e9';
