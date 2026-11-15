import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// [child] on the app background of [brightness], with the Monthra theme,
/// at the top start corner.
class TestFrame extends StatelessWidget {
  const new({
    required this.child,
    this.brightness = Brightness.light,
    super.key,
  });

  final Brightness brightness;
  final Widget child;

  @override
  Widget build(BuildContext context) => ShadApp(
    theme: monthraTheme(Brightness.light),
    darkTheme: monthraTheme(Brightness.dark),
    themeMode: brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
    home: Builder(
      builder: (context) {
        final theme = ShadTheme.of(context);
        return ColoredBox(
          color: theme.colorScheme.background,
          child: DefaultTextStyle(
            style: theme.textTheme.p.copyWith(
              color: theme.colorScheme.foreground,
            ),
            child: Padding(
              padding: const EdgeInsets.all(MonthraSpacing.x4),
              child: Align(alignment: Alignment.topLeft, child: child),
            ),
          ),
        );
      },
    ),
  );
}

extension PumpFrame on WidgetTester {
  /// Pumps [child] inside a [TestFrame] on a [size] window (pixel ratio 1).
  Future<void> pumpFrame(
    Widget child, {
    Brightness brightness = Brightness.light,
    Size size = const Size(800, 600),
  }) async {
    view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(view.reset);
    await pumpWidget(TestFrame(brightness: brightness, child: child));
  }

  /// Turns animations off, as the platform's reduce-motion setting does.
  void reduceMotion() {
    platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(platformDispatcher.clearAccessibilityFeaturesTestValue);
  }

  /// The theme in effect at [finder].
  ShadThemeData themeAt(Finder finder) => ShadTheme.of(element(finder));
}
