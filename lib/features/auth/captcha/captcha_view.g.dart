// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'captcha_view.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// This platform's view (overridden in widget tests, which have neither a
/// browser nor a webview).

@ProviderFor(captchaViewBuilder)
final captchaViewBuilderProvider = CaptchaViewBuilderProvider._();

/// This platform's view (overridden in widget tests, which have neither a
/// browser nor a webview).

final class CaptchaViewBuilderProvider
    extends
        $FunctionalProvider<
          CaptchaViewBuilder,
          CaptchaViewBuilder,
          CaptchaViewBuilder
        >
    with $Provider<CaptchaViewBuilder> {
  /// This platform's view (overridden in widget tests, which have neither a
  /// browser nor a webview).
  CaptchaViewBuilderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'captchaViewBuilderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$captchaViewBuilderHash();

  @$internal
  @override
  $ProviderElement<CaptchaViewBuilder> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CaptchaViewBuilder create(Ref ref) {
    return captchaViewBuilder(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CaptchaViewBuilder value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CaptchaViewBuilder>(value),
    );
  }
}

String _$captchaViewBuilderHash() =>
    r'a100232908455a4121aac4f7d1f005b16259b07b';
