import 'package:flutter/widgets.dart';

/// The form a captcha is solved on: the widget's `action`, which the server
/// checks against the route (`captcha.ActionLogin`/`ActionRegister`).
enum CaptchaAction { login, register }

/// Turnstile's widget sizes the page renders.
enum CaptchaSize {
  /// The container's width (at least 300 px), 65 px tall.
  flexible(65),

  /// 150 x 140 px, for narrower columns.
  compact(140);

  new(this.height);

  /// The size that fits [width].
  factory forWidth(double width) =>
      width >= flexibleMinWidth ? CaptchaSize.flexible : CaptchaSize.compact;

  /// Turnstile's narrowest flexible widget.
  static const double flexibleMinWidth = 300;

  final double height;
}

/// One widget to show: the page and its settings. A new request (or the
/// same one under a new key) loads the page again, which is how the app
/// resets the widget.
@immutable
class CaptchaRequest {
  const new({
    required this.page,
    required this.siteKey,
    required this.action,
    required this.brightness,
    required this.languageTag,
    required this.size,
    required this.background,
  });

  /// `web/turnstile.html` as the web app serves it (`Env.captchaPage`).
  final Uri page;
  final String siteKey;
  final CaptchaAction action;
  final Brightness brightness;

  /// `pt-BR`, `es-ES` or `en-US` (`AppLocale.tag`).
  final String languageTag;
  final CaptchaSize size;

  /// The color behind the widget, painted by the page so its frame never
  /// shows a backdrop of its own.
  final Color background;

  /// The page with its settings in the query string (read by turnstile.js).
  Uri get url => page.replace(
    queryParameters: {
      'sitekey': siteKey,
      'action': action.name,
      'theme': brightness.name,
      'lang': languageTag,
      'size': size.name,
      'bg': (background.toARGB32() & 0xFFFFFF)
          .toRadixString(16)
          .padLeft(6, '0')
          .toUpperCase(),
    },
  );

  @override
  bool operator ==(Object other) => other is CaptchaRequest && other.url == url;

  @override
  int get hashCode => url.hashCode;
}

/// Turnstile's own origin: its script, frames and challenges.
final Uri _cloudflare = Uri.parse('https://challenges.cloudflare.com');

/// Whether the webview may go to [target]: the main frame only ever shows
/// [page] (any query), and frames only Cloudflare's challenge or the blank
/// documents Turnstile builds them from. Everything else (the widget's
/// privacy and terms links, say) is refused.
bool allowCaptchaNavigation(
  Uri page,
  String target, {
  required bool isMainFrame,
}) {
  final uri = Uri.tryParse(target);
  if (uri == null) return false;
  if (isMainFrame) {
    return uri.scheme == page.scheme &&
        uri.host == page.host &&
        uri.port == page.port &&
        uri.path == page.path &&
        uri.userInfo.isEmpty;
  }
  if (target == 'about:blank' || target == 'about:srcdoc') return true;
  return uri.scheme == _cloudflare.scheme &&
      uri.host == _cloudflare.host &&
      uri.port == _cloudflare.port;
}
