// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_saver.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(fileSaver)
final fileSaverProvider = FileSaverProvider._();

final class FileSaverProvider
    extends $FunctionalProvider<FileSaver, FileSaver, FileSaver>
    with $Provider<FileSaver> {
  FileSaverProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fileSaverProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fileSaverHash();

  @$internal
  @override
  $ProviderElement<FileSaver> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FileSaver create(Ref ref) {
    return fileSaver(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FileSaver value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FileSaver>(value),
    );
  }
}

String _$fileSaverHash() => r'a672eb59db2f11cf6746840c0ef3f4493d0e6a92';
