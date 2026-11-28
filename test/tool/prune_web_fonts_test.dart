import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/prune_web_fonts.dart';

void main() {
  test('drops the Lucide weights the app does not draw with', () {
    final result = pruneFontManifest([
      {
        'family': 'Inter',
        'fonts': [
          {'asset': 'assets/fonts/inter/Inter-Regular.ttf', 'weight': 400},
        ],
      },
      {
        'family': 'packages/lucide_icons_flutter/Lucide',
        'fonts': [
          {'asset': 'packages/lucide_icons_flutter/assets/lucide.ttf'},
        ],
      },
      for (final w in [100, 300, 600])
        {
          'family': 'packages/lucide_icons_flutter/Lucide$w',
          'fonts': [
            {
              'asset':
                  'packages/lucide_icons_flutter/assets/build_font/'
                  'LucideVariable-w$w.ttf',
              'weight': w,
            },
          ],
        },
      {
        'family': 'packages/shadcn_ui/GeistMono',
        'fonts': [
          {'asset': 'packages/shadcn_ui/fonts/GeistMono%5Bwght%5D.ttf'},
        ],
      },
    ]);

    expect(result.manifest.map((e) => (e! as Map<String, Object?>)['family']), [
      'Inter',
      'packages/lucide_icons_flutter/Lucide',
      'packages/lucide_icons_flutter/Lucide300',
      'packages/shadcn_ui/GeistMono',
    ]);
    expect(result.dropped, [
      'packages/lucide_icons_flutter/assets/build_font/LucideVariable-w100.ttf',
      'packages/lucide_icons_flutter/assets/build_font/LucideVariable-w600.ttf',
    ]);
  });

  test('lib/ draws Lucide icons with the 1.5 px stroke (300) only', () {
    // "Silêncio" draws a 1.5 px stroke, and the other weights are pruned
    // from the web build: LucideIcons.house would show the 2 px weight.
    final icon = RegExp(r'\bLucideIcons\.([a-zA-Z][a-zA-Z0-9]*)');
    final drawn = RegExp('$lucideWeight(Dir)?\$');
    final offenders = <String>[];
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));
    for (final file in files) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        for (final match in icon.allMatches(lines[i])) {
          if (!drawn.hasMatch(match.group(1)!)) {
            offenders.add('${file.path}:${i + 1} ${match.group(0)}');
          }
        }
      }
    }
    expect(offenders, isEmpty);
  });
}
