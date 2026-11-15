import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/check_l10n.dart';

void main() {
  Map<String, Map<String, Object?>> valid() => {
    'app_en.arb': {
      '@@locale': 'en',
      'greeting': 'Hello, {name}',
      '@greeting': {
        'description': 'Greets the person.',
        'placeholders': {
          'name': {'type': 'String'},
        },
      },
      'items': '{count, plural, =0{No items} other{{count} items}}',
      '@items': {
        'description': 'How many items.',
        'placeholders': {
          'count': {'type': 'int'},
        },
      },
    },
    'app_es.arb': {
      '@@locale': 'es',
      'greeting': 'Hola, {name}',
      'items': '{count, plural, =0{Nada} other{{count} cosas}}',
    },
    'app_pt.arb': {
      '@@locale': 'pt',
      'greeting': 'Olá, {name}',
      'items': '{count, plural, =0{Nenhum} other{{count} itens}}',
    },
  };

  test('accepts files that agree', () {
    expect(checkArbs(valid()), isEmpty);
  });

  test('a key missing from a translation fails', () {
    final arbs = valid();
    arbs['app_pt.arb']!.remove('items');
    expect(checkArbs(arbs), ['app_pt.arb: missing items']);
  });

  test('a key only in a translation fails', () {
    final arbs = valid();
    arbs['app_es.arb']!['farewell'] = 'Adiós';
    expect(checkArbs(arbs), ['app_es.arb: farewell is not in app_en.arb']);
  });

  test('a template key without a description fails', () {
    final arbs = valid();
    (arbs['app_en.arb']!['@greeting']! as Map<String, Object?>).remove(
      'description',
    );
    arbs['app_en.arb']!.remove('@items');
    expect(checkArbs(arbs), [
      'app_en.arb: greeting has no @greeting.description',
      'app_en.arb: items has no @items.description',
    ]);
  });

  test('a translation that drops a placeholder fails', () {
    final arbs = valid();
    arbs['app_pt.arb']!['greeting'] = 'Olá';
    arbs['app_es.arb']!['items'] = 'muchas cosas';
    expect(checkArbs(arbs), [
      'app_es.arb: items misses {count}',
      'app_pt.arb: greeting misses {name}',
    ]);
  });

  test('an empty message fails', () {
    final arbs = valid();
    arbs['app_es.arb']!['greeting'] = ' ';
    expect(checkArbs(arbs), ['app_es.arb: greeting is empty']);
  });

  test('metadata outside the template fails', () {
    final arbs = valid();
    arbs['app_pt.arb']!['@greeting'] = {'description': 'Saudação.'};
    expect(checkArbs(arbs), [
      'app_pt.arb: @greeting belongs in app_en.arb only',
    ]);
  });

  test('a missing language file fails', () {
    final arbs = valid()..remove('app_es.arb');
    expect(checkArbs(arbs), ['app_es.arb: missing file']);
  });

  test("the app's ARB files agree", () {
    final arbs = {
      for (final file in Directory('lib/l10n').listSync().whereType<File>())
        if (file.path.endsWith('.arb'))
          file.uri.pathSegments.last:
              jsonDecode(file.readAsStringSync()) as Map<String, Object?>,
    };
    expect(arbs.keys, unorderedEquals(requiredArbs));
    expect(checkArbs(arbs), isEmpty);
  });
}
