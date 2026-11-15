import 'dart:convert';

import 'package:flutter/foundation.dart';

/// What the captcha page (`web/turnstile.js`) reports. It arrives as a JSON
/// string through the webview channel, or as a map through `postMessage` in
/// the web app; [CaptchaMessage.parse] reads both and drops anything else.
@immutable
sealed class CaptchaMessage {
  const new();

  /// The `source` every message of the page carries.
  static const String source = 'monthra-turnstile';

  /// The longest token Turnstile issues (and the API accepts).
  static const int maxTokenLength = 2048;

  static final RegExp _code = RegExp(r'^[A-Za-z0-9_-]{1,32}$');

  /// Reads [data], or returns null when it is not a message of the page: on
  /// iOS the webview channel is reachable from every frame (Cloudflare's
  /// included), so the shape is checked strictly.
  static CaptchaMessage? parse(Object? data) {
    var value = data;
    if (value is String) {
      if (value.length > maxTokenLength + 256) return null;
      try {
        value = jsonDecode(value);
      } on FormatException {
        return null;
      }
    }
    if (value is! Map || value['source'] != source) return null;
    return switch (value['type']) {
      'ready' => const CaptchaReady(),
      'token' => switch (value['token']) {
        final String token
            when token.isNotEmpty && token.length <= maxTokenLength =>
          CaptchaSolved(token),
        _ => null,
      },
      'expired' => const CaptchaExpired(),
      'error' => CaptchaFailed(switch (value['code']) {
        final String code when _code.hasMatch(code) => code,
        _ => 'unknown',
      }),
      'unsupported' => const CaptchaUnsupported(),
      _ => null,
    };
  }
}

/// The widget is on screen (it may still be checking).
final class CaptchaReady extends CaptchaMessage {
  const new();
}

/// The check passed: [token] goes with the next request, once.
final class CaptchaSolved extends CaptchaMessage {
  const new(this.token);

  final String token;

  @override
  bool operator ==(Object other) =>
      other is CaptchaSolved && other.token == token;

  @override
  int get hashCode => token.hashCode;

  @override
  String toString() => 'CaptchaSolved(<redacted>)';
}

/// The token ran out (300 s) or the challenge timed out; the widget gets
/// a new one by itself.
final class CaptchaExpired extends CaptchaMessage {
  const new();
}

/// The widget failed: [code] is Turnstile's error code, `load` when its
/// script could not load, `config` for a bad page address, `network` when
/// the page itself did not load.
final class CaptchaFailed extends CaptchaMessage {
  const new(this.code);

  final String code;

  @override
  bool operator ==(Object other) =>
      other is CaptchaFailed && other.code == code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => 'CaptchaFailed($code)';
}

/// This browser or webview cannot run Turnstile.
final class CaptchaUnsupported extends CaptchaMessage {
  const new();
}
