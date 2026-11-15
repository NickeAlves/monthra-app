import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:monthra/features/auth/captcha/captcha_message.dart';
import 'package:monthra/features/auth/captcha/captcha_request.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// The JavaScript channel the page posts to (`window.MonthraTurnstile`).
const String captchaChannel = 'MonthraTurnstile';

/// The captcha page in a webview, loaded from the web app
/// (`APP_PUBLIC_URL/turnstile.html`): Cloudflare's documented way for
/// WebViews, so the hostname Turnstile sees is the real one.
Widget platformCaptchaView(
  CaptchaRequest request, {
  required ValueChanged<CaptchaMessage> onMessage,
  required String title,
}) => _WebViewCaptcha(request: request, onMessage: onMessage, title: title);

class _WebViewCaptcha extends StatefulWidget {
  const new({
    required this.request,
    required this.onMessage,
    required this.title,
  });

  final CaptchaRequest request;
  final ValueChanged<CaptchaMessage> onMessage;
  final String title;

  @override
  State<_WebViewCaptcha> createState() => _WebViewCaptchaState();
}

class _WebViewCaptchaState extends State<_WebViewCaptcha> {
  final WebViewController _controller = WebViewController();

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final url = widget.request.url;
    await _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await _controller.setBackgroundColor(widget.request.background);
    await _controller.addJavaScriptChannel(
      captchaChannel,
      onMessageReceived: (message) =>
          _report(CaptchaMessage.parse(message.message)),
    );
    await _controller.setNavigationDelegate(
      NavigationDelegate(
        onNavigationRequest: (request) =>
            allowCaptchaNavigation(
              url,
              request.url,
              isMainFrame: request.isMainFrame,
            )
            ? NavigationDecision.navigate
            : NavigationDecision.prevent,
        onWebResourceError: (error) {
          if (error.isForMainFrame ?? false) {
            _report(const CaptchaFailed('network'));
          }
        },
        onHttpError: (error) {
          final uri = error.request?.uri;
          if (uri != null && uri.path == url.path && uri.host == url.host) {
            _report(const CaptchaFailed('network'));
          }
        },
      ),
    );
    await _controller.loadRequest(url);
  }

  void _report(CaptchaMessage? message) {
    if (message != null && mounted) widget.onMessage(message);
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: widget.title,
    container: true,
    child: WebViewWidget(controller: _controller),
  );
}
