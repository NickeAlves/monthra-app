import 'package:flutter/widgets.dart';
import 'package:monthra/core/config/env.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/features/auth/captcha/captcha_message.dart';
import 'package:monthra/features/auth/captcha/captcha_request.dart';
import 'package:monthra/features/auth/captcha/captcha_view.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// A local build that can show the captcha (`Env.captchaPage`).
final Env captchaEnv = Env(
  appEnv: AppEnv.local,
  apiBaseUrl: Uri.parse('http://localhost:8080'),
  appPublicUrl: Uri.parse('http://localhost:3000'),
  turnstileSiteKey: '1x00000000000000000000AA',
);

/// Stands in for the captcha page (tests have neither a browser nor a
/// webview): records each widget the app loads and lets the test post what
/// the page would.
final class FakeCaptcha {
  /// The requests of the widgets loaded, one per load (a new attempt
  /// loads the page again).
  final List<CaptchaRequest> loaded = [];

  /// The frame titles given to the views.
  final List<String> titles = [];

  ValueChanged<CaptchaMessage>? _post;

  /// The view, for `pumpMonthraApp(captcha: ...)`.
  CaptchaViewBuilder get builder =>
      (request, {required onMessage, required title}) => _FakeView(
        request: request,
        title: title,
        onCreated: (post) {
          loaded.add(request);
          titles.add(title);
          _post = post;
        },
        onMessage: onMessage,
      );

  /// Posts [message] from the widget loaded last.
  void post(CaptchaMessage message) {
    final post = _post;
    if (post == null) throw StateError('no captcha widget loaded');
    post(message);
  }

  /// The widget shows, then passes with [token].
  void solve([String token = 'token-1']) {
    post(const CaptchaReady());
    post(CaptchaSolved(token));
  }
}

class _FakeView extends StatefulWidget {
  const new({
    required this.request,
    required this.title,
    required this.onCreated,
    required this.onMessage,
  });

  final CaptchaRequest request;
  final String title;
  final ValueChanged<ValueChanged<CaptchaMessage>> onCreated;
  final ValueChanged<CaptchaMessage> onMessage;

  @override
  State<_FakeView> createState() => _FakeViewState();
}

class _FakeViewState extends State<_FakeView> {
  @override
  void initState() {
    super.initState();
    widget.onCreated((message) {
      if (mounted) widget.onMessage(message);
    });
  }

  /// A bordered box where Turnstile's widget would be (goldens).
  @override
  Widget build(BuildContext context) {
    final colors = ShadTheme.of(context).colorScheme;
    return Semantics(
      label: widget.title,
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.card,
          border: Border.all(color: colors.border),
          borderRadius: MonthraRadii.smAll,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}
