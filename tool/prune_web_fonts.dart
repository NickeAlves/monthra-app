// Drops from a web build the font families the app never draws with.
//
//   dart run tool/prune_web_fonts.dart build/web
//
// The web engine downloads every family of FontManifest.json before the
// first frame. lucide_icons_flutter declares six weight variants of its icon
// font (Lucide100 to Lucide600, ~1.4 MB gzipped) that icon tree shaking
// leaves whole because nothing uses them: the app and shadcn_ui draw with
// the base `Lucide` family only (test/tool/prune_web_fonts_test.dart keeps
// lib/ that way).
import 'dart:convert';
import 'dart:io';

/// Families removed from the web build.
final RegExp unusedFamily = RegExp(
  r'^packages/lucide_icons_flutter/Lucide[1-9]00$',
);

/// The manifest without the [unusedFamily] entries, and their asset paths.
({List<Object?> manifest, List<String> dropped}) pruneFontManifest(
  List<Object?> manifest,
) {
  final kept = <Object?>[];
  final dropped = <String>[];
  for (final entry in manifest) {
    final family = entry is Map<String, Object?> ? entry['family'] : null;
    if (family is String && unusedFamily.hasMatch(family)) {
      final fonts = (entry! as Map<String, Object?>)['fonts'];
      for (final font in fonts is List<Object?> ? fonts : const <Object?>[]) {
        final asset = font is Map<String, Object?> ? font['asset'] : null;
        if (asset is String) dropped.add(asset);
      }
    } else {
      kept.add(entry);
    }
  }
  return (manifest: kept, dropped: dropped);
}

void main(List<String> args) {
  if (args.length != 1) {
    stderr.writeln('usage: dart run tool/prune_web_fonts.dart <web build dir>');
    exit(64);
  }
  final assets = Directory('${args.single}/assets');
  final manifestFile = File('${assets.path}/FontManifest.json');
  final manifest = jsonDecode(manifestFile.readAsStringSync()) as List<Object?>;
  final result = pruneFontManifest(manifest);
  manifestFile.writeAsStringSync(jsonEncode(result.manifest));

  var bytes = 0;
  for (final asset in result.dropped) {
    // Manifest paths are URI-encoded, like the files' URLs.
    final file = File('${assets.path}/${Uri.decodeFull(asset)}');
    if (file.existsSync()) {
      bytes += file.lengthSync();
      file.deleteSync();
    }
  }
  stdout.writeln(
    'pruned ${result.dropped.length} unused fonts '
    '(${(bytes / 1024).round()} KB) from ${manifestFile.path}',
  );
}
