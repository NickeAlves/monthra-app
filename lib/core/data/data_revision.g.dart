// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_revision.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Counts the writes that change what the server sums (balances, invoices,
/// a month's flows). A screen that writes calls [DataRevision.bump] once
/// the server answered; providers that read sums watch it and read again.
/// Writers and readers never import each other (the dashboard reads the
/// accounts feature, which writes), and a read that no screen holds
/// anymore is simply dropped.

@ProviderFor(DataRevision)
final dataRevisionProvider = DataRevisionProvider._();

/// Counts the writes that change what the server sums (balances, invoices,
/// a month's flows). A screen that writes calls [DataRevision.bump] once
/// the server answered; providers that read sums watch it and read again.
/// Writers and readers never import each other (the dashboard reads the
/// accounts feature, which writes), and a read that no screen holds
/// anymore is simply dropped.
final class DataRevisionProvider extends $NotifierProvider<DataRevision, int> {
  /// Counts the writes that change what the server sums (balances, invoices,
  /// a month's flows). A screen that writes calls [DataRevision.bump] once
  /// the server answered; providers that read sums watch it and read again.
  /// Writers and readers never import each other (the dashboard reads the
  /// accounts feature, which writes), and a read that no screen holds
  /// anymore is simply dropped.
  DataRevisionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dataRevisionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dataRevisionHash();

  @$internal
  @override
  DataRevision create() => DataRevision();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$dataRevisionHash() => r'ca037e5b229ceeefae691f4c00320644b0d8410e';

/// Counts the writes that change what the server sums (balances, invoices,
/// a month's flows). A screen that writes calls [DataRevision.bump] once
/// the server answered; providers that read sums watch it and read again.
/// Writers and readers never import each other (the dashboard reads the
/// accounts feature, which writes), and a read that no screen holds
/// anymore is simply dropped.

abstract class _$DataRevision extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
