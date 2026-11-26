import 'package:flutter/widgets.dart';

/// No shadows on the app's surfaces ("Silêncio"): sections sit on the page
/// and cards stand out by a 1 px border. Dialogs, sheets and popovers keep
/// shadcn's own shadow, which separates them from what they cover.
abstract final class MonthraShadows {
  static const List<BoxShadow> none = [];
}
