import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/prune_web_fonts.dart';

void main() {
  test('drops the Lucide weight variants and nothing else', () {
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
      for (final w in [100, 600])
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
      'packages/shadcn_ui/GeistMono',
    ]);
    expect(result.dropped, [
      'packages/lucide_icons_flutter/assets/build_font/LucideVariable-w100.ttf',
      'packages/lucide_icons_flutter/assets/build_font/LucideVariable-w600.ttf',
    ]);
  });

  test('lib/ draws Lucide icons from the base family only', () {
    // LucideIcons.house100 and friends live in the pruned fonts.
    final weighted = RegExp(r'LucideIcons\.\w+?[1-9]00(Dir)?\b');
    final offenders = [
      for (final file in Directory('lib').listSync(recursive: true))
        if (file is File &&
            file.path.endsWith('.dart') &&
            weighted.hasMatch(file.readAsStringSync()))
          file.path,
    ];
    expect(offenders, isEmpty);
  });
}
