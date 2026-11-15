import 'package:monthra/features/auth/data/session_hint.dart';
import 'package:web/web.dart' as web;

/// The `localStorage` key of the hint.
const String sessionHintKey = 'monthra.session';

/// The hint in `localStorage`, shared by the tabs of this origin.
final class PlatformSessionHint implements SessionHint {
  new();

  @override
  bool get present {
    try {
      return web.window.localStorage.getItem(sessionHintKey) == '1';
    } on Object {
      // Storage blocked: ask the server, as if signed in.
      return true;
    }
  }

  @override
  set present(bool value) {
    try {
      if (value) {
        web.window.localStorage.setItem(sessionHintKey, '1');
      } else {
        web.window.localStorage.removeItem(sessionHintKey);
      }
    } on Object {
      // Storage blocked (private mode, quota): every visit asks the server.
    }
  }
}
