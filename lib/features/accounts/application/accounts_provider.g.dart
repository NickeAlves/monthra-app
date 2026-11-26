// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accounts_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Every account of the signed-in person, archived ones included, oldest
/// first, with balances up to the device's today. Reset when the
/// signed-in person changes, read again after a write
/// ([dataRevisionProvider]); empty signed out.

@ProviderFor(accounts)
final accountsProvider = AccountsProvider._();

/// Every account of the signed-in person, archived ones included, oldest
/// first, with balances up to the device's today. Reset when the
/// signed-in person changes, read again after a write
/// ([dataRevisionProvider]); empty signed out.

final class AccountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Account>>,
          List<Account>,
          FutureOr<List<Account>>
        >
    with $FutureModifier<List<Account>>, $FutureProvider<List<Account>> {
  /// Every account of the signed-in person, archived ones included, oldest
  /// first, with balances up to the device's today. Reset when the
  /// signed-in person changes, read again after a write
  /// ([dataRevisionProvider]); empty signed out.
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

String _$accountsHash() => r'4a855c872dff62bd82a8f4bd36bab1d8a67b74f9';

/// The invoices of card [accountId] from [from] to [to], their statuses
/// as of the device's today. Reset with the signed-in person, read again
/// after a write; empty signed out.

@ProviderFor(invoices)
final invoicesProvider = InvoicesFamily._();

/// The invoices of card [accountId] from [from] to [to], their statuses
/// as of the device's today. Reset with the signed-in person, read again
/// after a write; empty signed out.

final class InvoicesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Invoice>>,
          List<Invoice>,
          FutureOr<List<Invoice>>
        >
    with $FutureModifier<List<Invoice>>, $FutureProvider<List<Invoice>> {
  /// The invoices of card [accountId] from [from] to [to], their statuses
  /// as of the device's today. Reset with the signed-in person, read again
  /// after a write; empty signed out.
  InvoicesProvider._({
    required InvoicesFamily super.from,
    required (String, YearMonth, YearMonth) super.argument,
  }) : super(
         retry: noProviderRetry,
         name: r'invoicesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$invoicesHash();

  @override
  String toString() {
    return r'invoicesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<Invoice>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Invoice>> create(Ref ref) {
    final argument = this.argument as (String, YearMonth, YearMonth);
    return invoices(ref, argument.$1, argument.$2, argument.$3);
  }

  @override
  bool operator ==(Object other) {
    return other is InvoicesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$invoicesHash() => r'63cf151a42f2089cc03aab4c334846c3a8fc9aff';

/// The invoices of card [accountId] from [from] to [to], their statuses
/// as of the device's today. Reset with the signed-in person, read again
/// after a write; empty signed out.

final class InvoicesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<Invoice>>,
          (String, YearMonth, YearMonth)
        > {
  InvoicesFamily._()
    : super(
        retry: noProviderRetry,
        name: r'invoicesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The invoices of card [accountId] from [from] to [to], their statuses
  /// as of the device's today. Reset with the signed-in person, read again
  /// after a write; empty signed out.

  InvoicesProvider call(String accountId, YearMonth from, YearMonth to) =>
      InvoicesProvider._(argument: (accountId, from, to), from: this);

  @override
  String toString() => r'invoicesProvider';
}

/// The account writes of the screens. Each one tells the readers of sums
/// ([dataRevisionProvider]) once the server answered, so the lists, the
/// invoices and the dashboard read again.

@ProviderFor(accountWrites)
final accountWritesProvider = AccountWritesProvider._();

/// The account writes of the screens. Each one tells the readers of sums
/// ([dataRevisionProvider]) once the server answered, so the lists, the
/// invoices and the dashboard read again.

final class AccountWritesProvider
    extends $FunctionalProvider<AccountWrites, AccountWrites, AccountWrites>
    with $Provider<AccountWrites> {
  /// The account writes of the screens. Each one tells the readers of sums
  /// ([dataRevisionProvider]) once the server answered, so the lists, the
  /// invoices and the dashboard read again.
  AccountWritesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountWritesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountWritesHash();

  @$internal
  @override
  $ProviderElement<AccountWrites> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AccountWrites create(Ref ref) {
    return accountWrites(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountWrites value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountWrites>(value),
    );
  }
}

String _$accountWritesHash() => r'daa5d67ecbb03c3d966ebe2cae80b1f3b5d9df8a';
