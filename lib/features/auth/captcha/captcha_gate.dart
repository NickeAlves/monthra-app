import 'package:flutter/foundation.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/core/network/api_problem.dart';
import 'package:monthra/features/auth/captcha/captcha_message.dart';

/// Where the widget stands.
enum CaptchaStatus {
  /// The page is loading.
  loading,

  /// The widget is on screen, checking or waiting for a click.
  ready,

  /// A token is waiting to go with the next request.
  solved,

  /// The widget failed; [CaptchaGate.retry] loads it again.
  failed,

  /// This browser or webview cannot run Turnstile.
  unsupported,
}

/// The captcha of one form (sign-in or sign-up). The server asks for one
/// after repeated attempts (`captcha_required`), checks it before anything
/// else, and keeps asking while the attempts last, so once asked the form
/// keeps the widget. A token works once: each request takes it
/// ([take]) and the widget starts over for the next one ([attempt]).
class CaptchaGate extends ChangeNotifier {
  /// [available]: the build can show the widget (`Env.captchaPage`).
  /// Without it a captcha request keeps reading as "try again later".
  new({required this.available});

  final bool available;

  bool _needed = false;
  String? _token;
  int _attempt = 0;
  bool _resendOnSolve = false;
  CaptchaStatus _status = CaptchaStatus.loading;

  /// The server asked for a captcha: the form shows the widget.
  bool get needed => _needed;

  /// Counts the widgets shown: the view is keyed by it, so a new value loads
  /// the page again (a fresh token).
  int get attempt => _attempt;

  CaptchaStatus get status => _status;

  /// The form must wait for the widget before it sends.
  bool get waitingForToken => _needed && _token == null;

  /// Reads a refused request. True when it asked for a captcha that this
  /// build can show: the widget starts over. After `captcha_required` the
  /// form is sent again by itself as soon as it passes ([onMessage]); that
  /// resend carries a token, so it never gets `captcha_required` back. After
  /// `captcha_invalid` the person sends again: a server refusing every token
  /// (a misconfigured hostname list, say) must not meet a widget that passes
  /// by itself in an endless loop.
  bool onError(ApiException error) {
    if (!available ||
        error is! ApiProblemException ||
        !isCaptchaProblem(error.code)) {
      return false;
    }
    _needed = true;
    _resendOnSolve = error.code == ProblemCode.captchaRequired;
    _restart();
    return true;
  }

  /// The token for the request being sent (null while no captcha was asked
  /// for). Used once: the widget starts over for the next request.
  String? take() {
    if (!_needed) return null;
    final token = _token;
    _restart();
    return token;
  }

  /// Takes a message of the page. True when the form should be sent again
  /// now (the captcha it was refused for has passed).
  bool onMessage(CaptchaMessage message) {
    var resend = false;
    switch (message) {
      case CaptchaReady():
        if (_status == CaptchaStatus.loading) _status = CaptchaStatus.ready;
      case CaptchaSolved(:final token):
        _token = token;
        _status = CaptchaStatus.solved;
        resend = _resendOnSolve;
        _resendOnSolve = false;
      case CaptchaExpired():
        _token = null;
        _status = CaptchaStatus.ready;
      case CaptchaFailed():
        _token = null;
        _status = CaptchaStatus.failed;
      case CaptchaUnsupported():
        _token = null;
        _status = CaptchaStatus.unsupported;
    }
    notifyListeners();
    return resend;
  }

  /// Loads the widget again after a failure.
  void retry() => _restart();

  void _restart() {
    _token = null;
    _attempt++;
    _status = CaptchaStatus.loading;
    notifyListeners();
  }
}

/// Whether [code] is the server asking for (or refusing) a captcha.
bool isCaptchaProblem(ProblemCode? code) =>
    code == ProblemCode.captchaRequired || code == ProblemCode.captchaInvalid;
