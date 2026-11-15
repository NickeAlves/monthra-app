import 'package:monthra/features/auth/data/session_hint.dart';

/// Off the web the session lives in the `TokenStore`: nothing to keep.
final class PlatformSessionHint implements SessionHint {
  new();

  @override
  bool get present => false;

  @override
  set present(bool value) {}
}
