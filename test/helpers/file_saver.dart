import 'dart:typed_data';

import 'package:monthra/core/files/file_saver.dart';

/// What a [FakeFileSaver] does with the next file.
enum SaveOutcome { saved, cancelled, fails }

/// A [FileSaver] that records each file it gets and answers [outcome]
/// (or, while [queue] has any, its first entry).
final class FakeFileSaver implements FileSaver {
  new({this.outcome = SaveOutcome.saved});

  SaveOutcome outcome;
  final List<SaveOutcome> queue = [];
  final List<({String name, Uint8List bytes, String mimeType})> files = [];

  @override
  Future<bool> save({
    required String name,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    files.add((name: name, bytes: bytes, mimeType: mimeType));
    final next = queue.isEmpty ? outcome : queue.removeAt(0);
    return switch (next) {
      SaveOutcome.saved => true,
      SaveOutcome.cancelled => false,
      SaveOutcome.fails => throw const FileSaveException('fake'),
    };
  }
}
