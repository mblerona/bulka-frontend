// Regenerates lib/core/constants/app_strings.dart from lib/l10n/app_mk.arb.
//
//   dart run tool/gen_app_strings.dart
//
// Run it after adding or renaming a key in the .arb files (add the key to
// app_mk.arb, app_en.arb and app_sq.arb first, then `flutter gen-l10n`).
// Every ARB key becomes a getter that reads the current language; keys with
// placeholders (e.g. plurals) become methods. The "Same in every language"
// constants at the bottom of the current file are kept as they are.
import 'dart:convert';
import 'dart:io';

const _target = 'lib/core/constants/app_strings.dart';
const _template = 'lib/l10n/app_mk.arb';
const _constMarker = '  // ── Same in every language ──';

void main() {
  final current = File(_target).readAsStringSync();
  final markerAt = current.indexOf(_constMarker);
  if (markerAt < 0) {
    stderr.writeln('Marker "$_constMarker" not found in $_target.');
    exit(1);
  }
  // Everything from the marker down: the constants plus the closing brace.
  final constSection = current.substring(markerAt);

  final arb =
      jsonDecode(File(_template).readAsStringSync()) as Map<String, dynamic>;
  final b = StringBuffer()
    ..writeln('// GENERATED from lib/l10n/app_mk.arb by')
    ..writeln('// `dart run tool/gen_app_strings.dart` — edit the .arb files in')
    ..writeln('// lib/l10n/ (mk is the template), not the getters below. The')
    ..writeln('// constants at the bottom are kept as-is when regenerating.')
    ..writeln("import 'package:bulka_frontend/core/l10n/locale_controller.dart';")
    ..writeln("import 'package:bulka_frontend/l10n/app_localizations.dart';")
    ..writeln()
    ..writeln(
      '/// All user-facing text, in the language picked in [LocaleController].',
    )
    ..writeln('///')
    ..writeln(
      '/// Translated text is a getter (not `const`), so it always returns the',
    )
    ..writeln(
      "/// current language. Text that's the same in every language (symbols,",
    )
    ..writeln('/// emoji, sample data) stays `const` at the bottom.')
    ..writeln('class AppStrings {')
    ..writeln('  AppStrings._();')
    ..writeln()
    ..writeln(
      '  static AppLocalizations get _s => LocaleController.instance.strings;',
    )
    ..writeln();

  var count = 0;
  for (final key in arb.keys) {
    if (key.startsWith('@')) continue;
    count++;
    final meta = arb['@$key'] as Map<String, dynamic>?;
    final placeholders = meta?['placeholders'] as Map<String, dynamic>?;
    if (placeholders != null && placeholders.isNotEmpty) {
      final params = placeholders.entries
          .map((p) => '${(p.value as Map)['type'] ?? 'Object'} ${p.key}')
          .join(', ');
      b.writeln(
        '  static String $key($params) => '
        '_s.$key(${placeholders.keys.join(', ')});',
      );
    } else {
      b.writeln('  static String get $key => _s.$key;');
    }
  }
  b
    ..writeln()
    ..write(constSection);

  File(_target).writeAsStringSync(b.toString());
  Process.runSync('dart', ['format', _target], runInShell: true);
  stdout.writeln('Wrote $count getters to $_target.');
}
