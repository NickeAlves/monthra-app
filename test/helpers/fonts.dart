import 'dart:convert';

import 'package:flutter/services.dart';

/// Loads every font of the app bundle (FontManifest.json): Inter, the
/// Lucide icons and the fonts the packages bring.
Future<void> loadAppFonts() async {
  final manifest = await rootBundle.loadString('FontManifest.json');
  final families = (jsonDecode(manifest) as List<Object?>)
      .cast<Map<String, Object?>>();
  for (final family in families) {
    final loader = FontLoader(family['family']! as String);
    final fonts = (family['fonts']! as List<Object?>)
        .cast<Map<String, Object?>>();
    for (final font in fonts) {
      // Keys are URI-encoded in the manifest (Geist%5Bwght%5D.ttf), and
      // load() encodes them again.
      loader.addFont(rootBundle.load(Uri.decodeFull(font['asset']! as String)));
    }
    await loader.load();
  }
}
