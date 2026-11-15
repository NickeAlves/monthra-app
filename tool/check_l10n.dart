// Checks that the ARB files in lib/l10n agree (§7.6: CI fails when a key is
// missing from one of the three languages).
//
//   dart run tool/check_l10n.dart [arb dir]   (default lib/l10n)
//
// gen-l10n only warns about an untranslated message and shows the template's
// text instead; here every gap is an error.
import 'dart:convert';
import 'dart:io';

/// The template (`l10n.yaml`): its `@key` entries describe each message.
const String templateArb = 'app_en.arb';

/// One file per UI language.
const Set<String> requiredArbs = {'app_en.arb', 'app_es.arb', 'app_pt.arb'};

/// The problems in [arbs] (file name → decoded ARB), sorted; empty when
/// every file has the same messages, the template describes each of them,
/// and every translation uses the template's placeholders.
List<String> checkArbs(Map<String, Map<String, Object?>> arbs) {
  final problems = <String>[
    for (final file in requiredArbs.difference(arbs.keys.toSet()))
      '$file: missing file',
  ];
  final template = arbs[templateArb];
  if (template == null) return problems..sort();

  final keys = messageKeys(template);
  for (final key in keys) {
    final description = _meta(template, key)?['description'];
    if (description is! String || description.trim().isEmpty) {
      problems.add('$templateArb: $key has no @$key.description');
    }
  }
  for (final MapEntry(key: file, value: arb) in arbs.entries) {
    final fileKeys = messageKeys(arb);
    for (final key in keys.difference(fileKeys)) {
      problems.add('$file: missing $key');
    }
    for (final key in fileKeys.difference(keys)) {
      problems.add('$file: $key is not in $templateArb');
    }
    for (final key in fileKeys) {
      final value = arb[key];
      if (value is! String || value.trim().isEmpty) {
        problems.add('$file: $key is empty');
        continue;
      }
      for (final name in placeholders(template, key)) {
        final use = RegExp('\\{\\s*${RegExp.escape(name)}\\s*[,}]');
        if (!use.hasMatch(value)) problems.add('$file: $key misses {$name}');
      }
    }
    if (file != templateArb) {
      for (final key in arb.keys) {
        if (key.startsWith('@') && !key.startsWith('@@')) {
          problems.add('$file: $key belongs in $templateArb only');
        }
      }
    }
  }
  return problems..sort();
}

/// The message keys of [arb] (no `@key` metadata, no `@@locale`).
Set<String> messageKeys(Map<String, Object?> arb) =>
    arb.keys.where((k) => !k.startsWith('@')).toSet();

/// The placeholders the template declares for [key].
Iterable<String> placeholders(Map<String, Object?> template, String key) {
  final declared = _meta(template, key)?['placeholders'];
  return declared is Map<String, Object?> ? declared.keys : const [];
}

Map<String, Object?>? _meta(Map<String, Object?> template, String key) {
  final meta = template['@$key'];
  return meta is Map<String, Object?> ? meta : null;
}

void main(List<String> args) {
  final dir = Directory(args.isEmpty ? 'lib/l10n' : args.single);
  final arbs = {
    for (final file in dir.listSync().whereType<File>())
      if (file.path.endsWith('.arb'))
        file.uri.pathSegments.last:
            jsonDecode(file.readAsStringSync()) as Map<String, Object?>,
  };
  final problems = checkArbs(arbs);
  if (problems.isNotEmpty) {
    problems.forEach(stderr.writeln);
    final n = problems.length;
    stderr.writeln('l10n: $n problem${n == 1 ? '' : 's'} in ${dir.path}');
    exit(1);
  }
  final count = messageKeys(arbs[templateArb]!).length;
  stdout.writeln('l10n: ${arbs.length} ARB files agree on $count messages');
}
