import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/tokens/density.dart';

/// Gives a control drawn smaller than a touch target the whole target: on
/// touch layouts the box grows to 44 × 44 around [child], a tap anywhere in
/// it reaches [child], and assistive technologies read one node of that
/// size. On pointer layouts [child] keeps its own size.
///
/// Every `ShadButton` and `ShadIconButton` drawn at the theme's sizes sits
/// in one (buttons are drawn at 34 px; §4.4 asks 44 px for touch). The same
/// idea as the padding Material puts around its buttons.
class MonthraTapTarget extends StatelessWidget {
  const new({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final side = context.monthraDensity.minTapTarget;
    return MergeSemantics(
      child: _TapTargetBox(minSize: Size(side, side), child: child),
    );
  }
}

class _TapTargetBox extends SingleChildRenderObjectWidget {
  const new({required this.minSize, super.child});

  final Size minSize;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderTapTarget(minSize);

  @override
  void updateRenderObject(BuildContext context, _RenderTapTarget renderObject) {
    renderObject.minSize = minSize;
  }
}

class _RenderTapTarget extends RenderShiftedBox {
  new(this._minSize) : super(null);

  Size get minSize => _minSize;
  Size _minSize;
  set minSize(Size value) {
    if (_minSize == value) return;
    _minSize = value;
    markNeedsLayout();
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      math.max(child?.getMinIntrinsicWidth(height) ?? 0, minSize.width);

  @override
  double computeMaxIntrinsicWidth(double height) =>
      math.max(child?.getMaxIntrinsicWidth(height) ?? 0, minSize.width);

  @override
  double computeMinIntrinsicHeight(double width) =>
      math.max(child?.getMinIntrinsicHeight(width) ?? 0, minSize.height);

  @override
  double computeMaxIntrinsicHeight(double width) =>
      math.max(child?.getMaxIntrinsicHeight(width) ?? 0, minSize.height);

  Size _size(BoxConstraints constraints, ChildLayouter layoutChild) {
    final child = this.child;
    if (child == null) return constraints.constrain(minSize);
    final childSize = layoutChild(child, constraints);
    return constraints.constrain(
      Size(
        math.max(childSize.width, minSize.width),
        math.max(childSize.height, minSize.height),
      ),
    );
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      _size(constraints, ChildLayoutHelper.dryLayoutChild);

  @override
  double? computeDryBaseline(
    BoxConstraints constraints,
    TextBaseline baseline,
  ) {
    final child = this.child;
    if (child == null) return null;
    final result = child.getDryBaseline(constraints, baseline);
    if (result == null) return null;
    final childSize = child.getDryLayout(constraints);
    final size = getDryLayout(constraints);
    return result + (size.height - childSize.height) / 2;
  }

  @override
  void performLayout() {
    size = _size(constraints, ChildLayoutHelper.layoutChild);
    final child = this.child;
    if (child != null) {
      (child.parentData! as BoxParentData).offset = Alignment.center
          .alongOffset(size - child.size as Offset);
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!size.contains(position)) return false;
    if (super.hitTest(result, position: position)) return true;
    final child = this.child;
    if (child == null) return false;
    // A tap in the margin around the drawn control lands on its center.
    final center = child.size.center(Offset.zero);
    return result.addWithRawTransform(
      transform: MatrixUtils.forceToPoint(center),
      position: center,
      hitTest: (result, position) => child.hitTest(result, position: center),
    );
  }
}
