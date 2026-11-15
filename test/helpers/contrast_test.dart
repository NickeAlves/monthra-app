import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'contrast.dart';

/// [child] on [background], left to right.
Widget on(Color background, Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: ColoredBox(color: background, child: child),
);

const white = Color(0xFFFFFFFF);
const gray = Color(0xFFA0A0A0); // 2.6:1 on white
const darkGray = Color(0xFF767676); // 4.5:1 on white

void main() {
  testWidgets('flags text below 4.5:1 and passes text above', (tester) async {
    await tester.pumpWidget(
      on(
        white,
        const Column(
          children: [
            Text('faint', style: TextStyle(color: gray)),
            Text('fine', style: TextStyle(color: darkGray)),
          ],
        ),
      ),
    );
    final issues = contrastIssues(tester);
    expect(issues.map((i) => i.text), ['faint']);
    expect(issues.single.ratio, lessThan(3));
  });

  testWidgets('holds icons to 3:1', (tester) async {
    await tester.pumpWidget(
      on(
        white,
        const Column(
          children: [
            Icon(LucideIcons.tag, color: Color(0xFF8A8A8A)), // 3.4:1
            Icon(LucideIcons.tag, color: Color(0xFFB0B0B0)), // 2.1:1
          ],
        ),
      ),
    );
    final issues = contrastIssues(tester);
    expect(issues, hasLength(1));
    expect(issues.single.minimum, 3);
  });

  testWidgets('skips dimmed controls', (tester) async {
    await tester.pumpWidget(
      on(
        white,
        const Opacity(
          opacity: 0.5,
          child: Text('disabled', style: TextStyle(color: gray)),
        ),
      ),
    );
    expect(contrastIssues(tester), isEmpty);
  });

  testWidgets('blends translucent layers over the opaque one', (tester) async {
    await tester.pumpWidget(
      on(
        white,
        const ColoredBox(
          // Black at 60% over white: ~#666666, which white text reads on.
          color: Color(0x99000000),
          child: Text('on a scrim', style: TextStyle(color: white)),
        ),
      ),
    );
    expect(contrastIssues(tester), isEmpty);
  });
}
