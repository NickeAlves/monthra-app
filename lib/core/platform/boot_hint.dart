/// The hint `web/boot.js` reads before the first paint: the saved theme and
/// language, so a choice that differs from the system's never flashes the
/// other theme on the next visit. A no-op off the web (native splash
/// screens follow the system; they cannot read the app's preferences).
library;

export 'boot_hint_stub.dart' if (dart.library.js_interop) 'boot_hint_web.dart';
