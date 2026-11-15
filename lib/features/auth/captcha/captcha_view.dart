/// The captcha page on screen: an iframe in the web app, a webview on
/// devices. Tests replace it through [captchaViewBuilderProvider].
library;

import 'package:flutter/widgets.dart';
import 'package:monthra/features/auth/captcha/captcha_message.dart';
import 'package:monthra/features/auth/captcha/captcha_request.dart';
import 'package:monthra/features/auth/captcha/captcha_view_io.dart'
    if (dart.library.js_interop) 'package:monthra/features/auth/captcha/captcha_view_web.dart'
    as impl;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'captcha_view.g.dart';

/// Builds the view of [request], which reports the page's messages to
/// [onMessage]. [title] names the frame for screen readers.
typedef CaptchaViewBuilder = Widget Function(
  CaptchaRequest request, {
  required ValueChanged<CaptchaMessage> onMessage,
  required String title,
});

/// This platform's view (overridden in widget tests, which have neither a
/// browser nor a webview).
@Riverpod(keepAlive: true)
CaptchaViewBuilder captchaViewBuilder(Ref ref) => impl.platformCaptchaView;
