import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/features/auth/application/auth_controller.dart';
import 'package:monthra/features/auth/application/auth_state.dart';
import 'package:monthra/features/settings/application/unsaved_recovery_codes.dart';
import 'package:monthra/l10n/l10n.dart';

/// The `onExit` of the pages that show new recovery codes: while they are
/// unsaved ([UnsavedRecoveryCodes]), leaving by any way (the back link,
/// the platform's back, the menu) asks first. Never in the way of a
/// sign-out or an expired session.
FutureOr<bool> confirmLeavingRecoveryCodes(
  BuildContext context,
  GoRouterState state,
) async {
  final container = ProviderScope.containerOf(context, listen: false);
  if (!container.read(unsavedRecoveryCodesProvider)) return true;
  if (container.read(authControllerProvider) is! SignedIn) return true;
  final l10n = context.l10n;
  final leave = await showMonthraConfirm(
    context,
    title: l10n.recoveryCodesLeaveTitle,
    description: l10n.recoveryCodesLeaveDescription,
    confirmLabel: l10n.recoveryCodesLeave,
    cancelLabel: l10n.recoveryCodesStay,
    barrierLabel: l10n.appClose,
    destructive: true,
  );
  if (leave) container.read(unsavedRecoveryCodesProvider.notifier).saved();
  return leave;
}
