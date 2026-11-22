import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ProviderListenableSelect;
import 'package:monthra/features/auth/application/auth_controller.dart';
import 'package:monthra/features/auth/application/auth_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'unsaved_recovery_codes.g.dart';

/// New recovery codes are on screen and not saved yet (their checkbox is
/// unticked): leaving their page asks first. Reset when the signed-in
/// person changes, so a sign-out never waits on it.
@Riverpod(keepAlive: true)
class UnsavedRecoveryCodes extends _$UnsavedRecoveryCodes {
  @override
  bool build() {
    ref.watch(
      authControllerProvider.select((s) => s is SignedIn ? s.me.id : null),
    );
    return false;
  }

  void shown() => state = true;

  void saved() => state = false;
}
