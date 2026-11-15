import 'package:flutter/widgets.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:monthra/app/app.dart';
import 'package:monthra/core/config/env.dart';

void main() {
  // Clean paths on the web: the email links are /verify-email#token=… and
  // /reset-password#token=…, with the token kept in the fragment.
  usePathUrlStrategy();
  runApp(MonthraApp(env: Env.fromEnvironment()));
}
