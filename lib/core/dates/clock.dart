import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clock.g.dart';

/// The device's current time. Read it through this provider (not
/// `DateTime.now()`) where "today" or "this month" decides what is shown or
/// asked for, so tests can hold the date still.
@Riverpod(keepAlive: true)
DateTime Function() clock(Ref ref) => DateTime.now;
