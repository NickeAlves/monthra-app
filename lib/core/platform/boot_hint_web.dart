import 'dart:convert';

import 'package:web/web.dart' as web;

/// The localStorage key `web/boot.js` reads; keep both in step.
const String bootHintKey = 'monthra.boot';

/// Saves `{"lang": languageTag, "theme": theme}` for `web/boot.js`; a null
/// [theme] (system) leaves the splash on `prefers-color-scheme`. Its own
/// key, so boot.js never depends on the shared_preferences storage format.
void saveBootHint({required String languageTag, String? theme}) {
  try {
    web.window.localStorage.setItem(
      bootHintKey,
      jsonEncode({'lang': languageTag, 'theme': ?theme}),
    );
  } on Object {
    // Storage blocked (private mode, quota): the next visit simply opens
    // in the system theme, as before any choice.
  }
}
