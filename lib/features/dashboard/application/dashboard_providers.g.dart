// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The summary of [month] for the signed-in person, with balances up to
/// the device's today; null signed out. Reset when the person changes.
/// The writing features invalidate it after each write (the server drops
/// its own cache then).

@ProviderFor(dashboardSummary)
final dashboardSummaryProvider = DashboardSummaryFamily._();

/// The summary of [month] for the signed-in person, with balances up to
/// the device's today; null signed out. Reset when the person changes.
/// The writing features invalidate it after each write (the server drops
/// its own cache then).

final class DashboardSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<DashboardSummary?>,
          DashboardSummary?,
          FutureOr<DashboardSummary?>
        >
    with
        $FutureModifier<DashboardSummary?>,
        $FutureProvider<DashboardSummary?> {
  /// The summary of [month] for the signed-in person, with balances up to
  /// the device's today; null signed out. Reset when the person changes.
  /// The writing features invalidate it after each write (the server drops
  /// its own cache then).
  DashboardSummaryProvider._({
    required DashboardSummaryFamily super.from,
    required YearMonth super.argument,
  }) : super(
         retry: noProviderRetry,
         name: r'dashboardSummaryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dashboardSummaryHash();

  @override
  String toString() {
    return r'dashboardSummaryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<DashboardSummary?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DashboardSummary?> create(Ref ref) {
    final argument = this.argument as YearMonth;
    return dashboardSummary(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DashboardSummaryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dashboardSummaryHash() => r'0e7715c3ad7ebf0099e291792be2e6af388f321d';

/// The summary of [month] for the signed-in person, with balances up to
/// the device's today; null signed out. Reset when the person changes.
/// The writing features invalidate it after each write (the server drops
/// its own cache then).

final class DashboardSummaryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<DashboardSummary?>, YearMonth> {
  DashboardSummaryFamily._()
    : super(
        retry: noProviderRetry,
        name: r'dashboardSummaryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The summary of [month] for the signed-in person, with balances up to
  /// the device's today; null signed out. Reset when the person changes.
  /// The writing features invalidate it after each write (the server drops
  /// its own cache then).

  DashboardSummaryProvider call(YearMonth month) =>
      DashboardSummaryProvider._(argument: month, from: this);

  @override
  String toString() => r'dashboardSummaryProvider';
}

/// The dashboard of [month]: its summary joined with the accounts and
/// categories, the profile's currency first; null signed out.

@ProviderFor(dashboardView)
final dashboardViewProvider = DashboardViewFamily._();

/// The dashboard of [month]: its summary joined with the accounts and
/// categories, the profile's currency first; null signed out.

final class DashboardViewProvider
    extends
        $FunctionalProvider<
          AsyncValue<DashboardView?>,
          DashboardView?,
          FutureOr<DashboardView?>
        >
    with $FutureModifier<DashboardView?>, $FutureProvider<DashboardView?> {
  /// The dashboard of [month]: its summary joined with the accounts and
  /// categories, the profile's currency first; null signed out.
  DashboardViewProvider._({
    required DashboardViewFamily super.from,
    required YearMonth super.argument,
  }) : super(
         retry: noProviderRetry,
         name: r'dashboardViewProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dashboardViewHash();

  @override
  String toString() {
    return r'dashboardViewProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<DashboardView?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DashboardView?> create(Ref ref) {
    final argument = this.argument as YearMonth;
    return dashboardView(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DashboardViewProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dashboardViewHash() => r'44af634385f85c5c64cb68b4d1d76c0655589ab4';

/// The dashboard of [month]: its summary joined with the accounts and
/// categories, the profile's currency first; null signed out.

final class DashboardViewFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<DashboardView?>, YearMonth> {
  DashboardViewFamily._()
    : super(
        retry: noProviderRetry,
        name: r'dashboardViewProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The dashboard of [month]: its summary joined with the accounts and
  /// categories, the profile's currency first; null signed out.

  DashboardViewProvider call(YearMonth month) =>
      DashboardViewProvider._(argument: month, from: this);

  @override
  String toString() => r'dashboardViewProvider';
}
