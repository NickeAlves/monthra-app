import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/widgets.dart';
import 'package:monthra/features/auth/captcha/captcha_message.dart';
import 'package:monthra/features/auth/captcha/captcha_request.dart';
import 'package:web/web.dart' as web;

/// The captcha page in an iframe of the web app (same origin: the app's CSP
/// allows `frame-src 'self'`, the page's allows `frame-ancestors 'self'`).
Widget platformCaptchaView(
  CaptchaRequest request, {
  required ValueChanged<CaptchaMessage> onMessage,
  required String title,
}) => _FrameCaptcha(request: request, onMessage: onMessage, title: title);

class _FrameCaptcha extends StatefulWidget {
  const new({
    required this.request,
    required this.onMessage,
    required this.title,
  });

  final CaptchaRequest request;
  final ValueChanged<CaptchaMessage> onMessage;
  final String title;

  @override
  State<_FrameCaptcha> createState() => _FrameCaptchaState();
}

class _FrameCaptchaState extends State<_FrameCaptcha> {
  web.HTMLIFrameElement? _frame;
  StreamSubscription<web.MessageEvent>? _messages;

  @override
  void initState() {
    super.initState();
    _messages = web.window.onMessage.listen(_onMessage);
  }

  @override
  void dispose() {
    unawaited(_messages?.cancel());
    super.dispose();
  }

  /// Takes messages from this frame only: same origin, and the frame's own
  /// window (another frame of the origin, or another widget's, is ignored).
  void _onMessage(web.MessageEvent event) {
    final frame = _frame;
    if (frame == null || !mounted) return;
    if (event.origin != web.window.location.origin) return;
    if (!event.source.strictEquals(frame.contentWindow).toDart) return;
    final message = CaptchaMessage.parse(event.data.dartify());
    if (message != null) widget.onMessage(message);
  }

  @override
  Widget build(BuildContext context) => HtmlElementView.fromTagName(
    tagName: 'iframe',
    onElementCreated: (element) {
      final frame = element as web.HTMLIFrameElement
        ..title = widget.title
        ..src = widget.request.url.toString()
        ..referrerPolicy = 'same-origin';
      frame.style
        ..border = '0'
        ..width = '100%'
        ..height = '100%'
        ..display = 'block';
      _frame = frame;
    },
  );
}
