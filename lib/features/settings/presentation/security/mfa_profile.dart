import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/features/auth/application/auth_controller.dart';
import 'package:monthra/features/auth/application/auth_state.dart';
import 'package:monthra/features/auth/data/models/me.dart';

/// Watches whether two-step verification is on for the person signed in
/// (false for a frame while signing out).
bool watchMfaEnabled(WidgetRef ref) => ref.watch(
  authControllerProvider.select((s) => s is SignedIn && s.me.mfa.enabled),
);

/// Applies the MFA state a call just answered to the profile.
void applyMfa(WidgetRef ref, MfaStatus mfa) {
  final auth = ref.read(authControllerProvider);
  if (auth is! SignedIn) return;
  ref
      .read(authControllerProvider.notifier)
      .updateMe(auth.me.id, (me) => me.copyWith(mfa: mfa));
}

/// Reads the profile again after a `409` that says MFA changed elsewhere
/// (another device). A failure leaves the page as it knows the profile.
Future<void> reloadMfa(WidgetRef ref) async {
  try {
    await ref.read(authControllerProvider.notifier).refreshProfile();
  } on ApiException {
    // Nothing better to show than what the page already knows.
  }
}
