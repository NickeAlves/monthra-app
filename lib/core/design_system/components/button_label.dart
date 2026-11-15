import 'package:flutter/widgets.dart';

/// The label of a `ShadButton`: one line that shortens with an ellipsis
/// when space runs out (large text sizes, narrow screens) instead of
/// overflowing. The button puts its child straight into a `Row`, so this
/// can be [Flexible]; assistive technologies still read the whole text.
class ButtonLabel extends StatelessWidget {
  const new(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) =>
      Flexible(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis));
}
