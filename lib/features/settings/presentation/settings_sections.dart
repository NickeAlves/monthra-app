import 'package:flutter/widgets.dart';
import 'package:monthra/features/settings/presentation/sections/preferences_section.dart';
import 'package:monthra/features/settings/presentation/sections/profile_section.dart';

/// The cards of the settings page, top to bottom: the one place a new
/// section goes (settings-security adds security and sessions,
/// settings-data the export and the account deletion). A flow that needs a
/// screen of its own becomes a sub-route of the settings destination, so
/// the menu keeps Settings selected.
const List<Widget> settingsSections = [ProfileSection(), PreferencesSection()];
