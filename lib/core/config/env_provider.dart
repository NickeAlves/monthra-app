import 'package:monthra/core/config/env.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'env_provider.g.dart';

/// This build's configuration, read in `main` ([Env.fromEnvironment]) and
/// passed in with `envProvider.overrideWithValue` (see `appOverrides`).
@Riverpod(keepAlive: true)
Env env(Ref ref) =>
    throw StateError('envProvider is overridden in main (appOverrides)');
