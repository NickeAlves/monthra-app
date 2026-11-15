// Runs before the page paints: applies the theme and language the person
// chose last time (lib/core/platform/boot_hint_web.dart saves them), so a
// choice that differs from the system's never flashes the other theme.
// Without a hint the splash follows prefers-color-scheme.
(function () {
  try {
    var hint = JSON.parse(window.localStorage.getItem('monthra.boot') || '{}');
    var root = document.documentElement;
    if (hint.theme === 'light' || hint.theme === 'dark') {
      root.setAttribute('data-theme', hint.theme);
    }
    if (typeof hint.lang === 'string' && /^[a-z]{2}-[A-Z]{2}$/.test(hint.lang)) {
      root.setAttribute('lang', hint.lang);
    }
  } catch (_) {
    // Storage blocked or a malformed hint: keep the defaults.
  }
})();
