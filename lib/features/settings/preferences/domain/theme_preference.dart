import 'package:flutter/material.dart' show ThemeMode;

/// The theme choice (§7.6), with the values the API stores
/// (server: `domain.Theme`).
enum ThemePreference {
  system('system', ThemeMode.system),
  light('light', ThemeMode.light),
  dark('dark', ThemeMode.dark);

  new(this.wire, this.themeMode);

  /// Null when [wire] is not one of the three.
  static ThemePreference? fromWire(String? wire) => _byWire[wire];

  static final Map<String, ThemePreference> _byWire = {
    for (final t in values) t.wire: t,
  };

  /// `system`, `light` or `dark`.
  final String wire;

  final ThemeMode themeMode;
}
