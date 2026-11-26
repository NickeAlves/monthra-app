import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'data_revision.g.dart';

/// Counts the writes that change what the server sums (balances, invoices,
/// a month's flows). A screen that writes calls [DataRevision.bump] once
/// the server answered; providers that read sums watch it and read again.
/// Writers and readers never import each other (the dashboard reads the
/// accounts feature, which writes), and a read that no screen holds
/// anymore is simply dropped.
@Riverpod(keepAlive: true)
class DataRevision extends _$DataRevision {
  @override
  int build() => 0;

  void bump() => state++;
}
