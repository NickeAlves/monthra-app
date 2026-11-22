import 'package:monthra/features/auth/application/auth_controller.dart';
import 'package:monthra/features/auth/application/auth_state.dart';

/// An [AuthController] that starts in [initial] without looking for a
/// session (no token store, no `GET /me`); the rest behaves as the real one.
class StubAuthController extends AuthController {
  new(this.initial);

  final AuthState initial;

  @override
  AuthState build() => initial;
}
