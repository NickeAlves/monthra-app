// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Changes to the signed-in profile: the name, and the preferences synced
/// with `PATCH /me/preferences` (§7.6).
///
/// - Language and theme apply (and are saved on the device) at once; the
///   request follows. Currency and budget alerts live only in the profile:
///   they show from [ProfileEdits.pending] until the answer.
/// - Requests go one at a time, in order, and the choices made while one
///   is on its way go together in the next: quick changes cost two
///   requests at most and the last choice wins.
/// - A failure puts a field back as the profile has it, unless a newer
///   choice for it is queued, and reports [ProfileEdits.failure] (the shell
///   shows it).
/// - Signed out (the catalog's pickers), the language and theme change on
///   the device only. Sign-in and start-up never come through here: the
///   profile's values replace the local ones there, so they send nothing.
/// - An answer that arrives after the person signed out, or someone else
///   signed in, is dropped.

@ProviderFor(ProfileController)
final profileControllerProvider = ProfileControllerProvider._();

/// Changes to the signed-in profile: the name, and the preferences synced
/// with `PATCH /me/preferences` (§7.6).
///
/// - Language and theme apply (and are saved on the device) at once; the
///   request follows. Currency and budget alerts live only in the profile:
///   they show from [ProfileEdits.pending] until the answer.
/// - Requests go one at a time, in order, and the choices made while one
///   is on its way go together in the next: quick changes cost two
///   requests at most and the last choice wins.
/// - A failure puts a field back as the profile has it, unless a newer
///   choice for it is queued, and reports [ProfileEdits.failure] (the shell
///   shows it).
/// - Signed out (the catalog's pickers), the language and theme change on
///   the device only. Sign-in and start-up never come through here: the
///   profile's values replace the local ones there, so they send nothing.
/// - An answer that arrives after the person signed out, or someone else
///   signed in, is dropped.
final class ProfileControllerProvider
    extends $NotifierProvider<ProfileController, ProfileEdits> {
  /// Changes to the signed-in profile: the name, and the preferences synced
  /// with `PATCH /me/preferences` (§7.6).
  ///
  /// - Language and theme apply (and are saved on the device) at once; the
  ///   request follows. Currency and budget alerts live only in the profile:
  ///   they show from [ProfileEdits.pending] until the answer.
  /// - Requests go one at a time, in order, and the choices made while one
  ///   is on its way go together in the next: quick changes cost two
  ///   requests at most and the last choice wins.
  /// - A failure puts a field back as the profile has it, unless a newer
  ///   choice for it is queued, and reports [ProfileEdits.failure] (the shell
  ///   shows it).
  /// - Signed out (the catalog's pickers), the language and theme change on
  ///   the device only. Sign-in and start-up never come through here: the
  ///   profile's values replace the local ones there, so they send nothing.
  /// - An answer that arrives after the person signed out, or someone else
  ///   signed in, is dropped.
  ProfileControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileControllerHash();

  @$internal
  @override
  ProfileController create() => ProfileController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileEdits value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileEdits>(value),
    );
  }
}

String _$profileControllerHash() => r'72f51b58a504f6f65a5c2a6e2f82f2041c5a7c58';

/// Changes to the signed-in profile: the name, and the preferences synced
/// with `PATCH /me/preferences` (§7.6).
///
/// - Language and theme apply (and are saved on the device) at once; the
///   request follows. Currency and budget alerts live only in the profile:
///   they show from [ProfileEdits.pending] until the answer.
/// - Requests go one at a time, in order, and the choices made while one
///   is on its way go together in the next: quick changes cost two
///   requests at most and the last choice wins.
/// - A failure puts a field back as the profile has it, unless a newer
///   choice for it is queued, and reports [ProfileEdits.failure] (the shell
///   shows it).
/// - Signed out (the catalog's pickers), the language and theme change on
///   the device only. Sign-in and start-up never come through here: the
///   profile's values replace the local ones there, so they send nothing.
/// - An answer that arrives after the person signed out, or someone else
///   signed in, is dropped.

abstract class _$ProfileController extends $Notifier<ProfileEdits> {
  ProfileEdits build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ProfileEdits, ProfileEdits>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ProfileEdits, ProfileEdits>,
              ProfileEdits,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
