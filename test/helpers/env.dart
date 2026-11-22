import 'package:monthra/core/config/env.dart';

final Env localEnv = Env(
  appEnv: AppEnv.local,
  apiBaseUrl: Uri.parse('http://localhost:8080'),
);
