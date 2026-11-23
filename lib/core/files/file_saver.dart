import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'file_saver.g.dart';

@Riverpod(keepAlive: true)
FileSaver fileSaver(Ref ref) => const PlatformFileSaver();

/// Hands a file the app made (the data export, the recovery codes) to the
/// person: the system's "Save as" on a device, a download in a browser.
abstract interface class FileSaver {
  /// Saves [bytes] as [name] (with its extension). True once saved, false
  /// when the person cancelled the dialog; throws [FileSaveException] when
  /// it could not be written.
  Future<bool> save({
    required String name,
    required Uint8List bytes,
    required String mimeType,
  });
}

/// The file could not be saved (the platform refused or failed to write).
final class FileSaveException implements Exception {
  const new([this.cause]);

  /// The underlying error, for the logs.
  final Object? cause;

  @override
  String toString() => 'FileSaveException($cause)';
}

/// [FileSaver] on file_picker: Android's "create document" (the Storage
/// Access Framework, no storage permission), iOS's document exporter ("Save
/// to Files"), and a download in a browser. The whole file sits in memory,
/// which an account's export can afford.
class PlatformFileSaver implements FileSaver {
  const new();

  @override
  Future<bool> save({
    required String name,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    final Uri? saved;
    try {
      saved = await FilePicker.saveFile(
        fileName: name,
        bytes: bytes,
        mimeType: mimeType,
      );
    } on PlatformException catch (e) {
      throw FileSaveException(e);
    }
    // A browser download answers null: the page never learns where it went.
    return kIsWeb || saved != null;
  }
}
