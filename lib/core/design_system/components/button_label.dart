import 'package:flutter/widgets.dart';

/// The label of a `ShadButton`: one line that shortens with an ellipsis
/// when space runs out (large text sizes, narrow screens) instead of
/// overflowing. The button puts its child straight into a `Row`, so this
/// can be [Flexible]; assistive technologies still read the whole text.
class ButtonLabel extends StatelessWidget {
  const new(this.text, {this.semanticsLabel, super.key});

  final String text;

  /// What assistive technologies read instead of [text], when the short
  /// text needs its context ("Sign out" -> "Sign out Chrome on macOS").
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) => Flexible(
    child: Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      semanticsLabel: semanticsLabel,
    ),
  );
}
