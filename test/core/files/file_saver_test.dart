import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/files/file_saver.dart';

void main() {
  late FilePickerPlatform original;
  late _FakePicker picker;

  setUp(() {
    original = FilePickerPlatform.instance;
    FilePickerPlatform.instance = picker = _FakePicker();
  });
  tearDown(() => FilePickerPlatform.instance = original);

  Future<bool> save() => const PlatformFileSaver().save(
    name: 'monthra-data-2026-11-22.zip',
    bytes: Uint8List.fromList([80, 75, 5, 6]),
    mimeType: 'application/zip',
  );

  test('hands the file to the save dialog', () async {
    picker.answer = () => Uri.file('/files/monthra-data-2026-11-22.zip');

    expect(await save(), isTrue);
    final file = picker.saved.single;
    expect(file.name, 'monthra-data-2026-11-22.zip');
    expect(file.bytes, [80, 75, 5, 6]);
    expect(file.mimeType, 'application/zip');
  });

  test('a cancelled dialog saves nothing', () async {
    picker.answer = () => null;

    expect(await save(), isFalse);
  });

  test('a platform failure is a FileSaveException', () async {
    picker.answer = () => throw PlatformException(code: 'save_file_error');

    await expectLater(save(), throwsA(isA<FileSaveException>()));
  });
}

final class _FakePicker extends FilePickerPlatform {
  Uri? Function() answer = () => null;
  final List<({String name, List<int> bytes, String mimeType})> saved = [];

  @override
  Future<Uri?> saveFile({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
    String? dialogTitle,
    String? initialDirectory,
    void Function(FilePickerStatus)? onFileSaving,
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async {
    saved.add((name: fileName, bytes: bytes.toList(), mimeType: mimeType));
    return answer();
  }
}
