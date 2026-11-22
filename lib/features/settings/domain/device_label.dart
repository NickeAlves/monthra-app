/// What a session's `User-Agent` tells about its device: the browser and
/// system families (brand names, never translated), or the Monthra app.
typedef DeviceLabel = ({String? browser, String? os, bool app});

final RegExp _monthraApp = RegExp(r'^Monthra \(([^)]+)\)');

/// Reads [userAgent] as the server stored it (cut to 256 bytes): the
/// Monthra apps' own (`Monthra (iOS)`, see `nativeUserAgent`) and the
/// common browsers. Nothing it knows gives nulls.
DeviceLabel describeUserAgent(String userAgent) {
  final app = _monthraApp.firstMatch(userAgent);
  if (app != null) return (browser: null, os: app.group(1), app: true);
  bool has(String s) => userAgent.contains(s);
  final os = switch (true) {
    _ when has('iPad') => 'iPadOS',
    _ when has('iPhone') || has('iPod') => 'iOS',
    _ when has('Android') => 'Android',
    _ when has('CrOS') => 'ChromeOS',
    _ when has('Windows') => 'Windows',
    _ when has('Macintosh') || has('Mac OS X') => 'macOS',
    _ when has('Linux') => 'Linux',
    _ => null,
  };
  // Order matters: Edge, Opera and Samsung Internet also say Chrome, and
  // every Chromium and iOS browser says Safari.
  final browser = switch (true) {
    _ when has('Edg/') || has('EdgA/') || has('EdgiOS/') => 'Edge',
    _ when has('OPR/') || has('OPT/') => 'Opera',
    _ when has('SamsungBrowser/') => 'Samsung Internet',
    _ when has('Firefox/') || has('FxiOS/') => 'Firefox',
    _ when has('Chrome/') || has('CriOS/') => 'Chrome',
    _ when has('Safari/') && has('Version/') => 'Safari',
    _ => null,
  };
  return (browser: browser, os: os, app: false);
}
