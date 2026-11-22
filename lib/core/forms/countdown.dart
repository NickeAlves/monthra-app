import 'dart:async';

import 'package:flutter/foundation.dart';

/// How long a resend button waits before it can send another email.
const Duration resendCooldown = Duration(seconds: 60);

/// Seconds left before an action may run again (a resend, a rate-limited
/// sign-in); zero when it may.
class Countdown extends ValueNotifier<int> {
  new() : super(0);

  Timer? _timer;

  bool get running => value > 0;

  void start(Duration duration) {
    _timer?.cancel();
    value = duration.inSeconds.clamp(1, 3600);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      value = value - 1;
      if (value <= 0) timer.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
