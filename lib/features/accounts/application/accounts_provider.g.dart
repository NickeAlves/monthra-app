// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accounts_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Every account of the signed-in person, archived ones included, oldest
/// first. Reset when the signed-in person changes; empty signed out.

@ProviderFor(accounts)
final accountsProvider = AccountsProvider._();

/// Every account of the signed-in person, archived ones included, oldest
/// first. Reset when the signed-in person changes; empty signed out.

final class AccountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Account>>,
          List<Account>,
          FutureOr<List<Account>>
        >
    with $FutureModifier<List<Account>>, $FutureProvider<List<Account>> {
  /// Every account of the signed-in person, archived ones included, oldest
  /// first. Reset when the signed-in person changes; empty signed out.
  AccountsProvider._()
    : super(
        from: null,
        argument: null,
        retry: noProviderRetry,
        name: r'accountsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountsHash();

  @$internal
  @override
  $FutureProviderElement<List<Account>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Account>> create(Ref ref) {
    return accounts(ref);
  }
}

String _$accountsHash() => r'52b6871799ae4b0972155815b58b5c6389533609';
