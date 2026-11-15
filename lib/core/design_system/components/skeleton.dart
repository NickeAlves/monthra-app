import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/tokens/colors.dart';
import 'package:monthra/core/design_system/tokens/motion.dart';
import 'package:monthra/core/design_system/tokens/radii.dart';
import 'package:monthra/core/design_system/tokens/spacing.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// The opacity of every skeleton at frame time [t]: from 1 down to 0.4 and
/// back once per [MonthraMotion.pulse]. Every skeleton reads the same
/// clock, so a screen of them pulses together.
double skeletonOpacity(Duration t) {
  final period = MonthraMotion.pulse.inMicroseconds;
  final phase = (t.inMicroseconds % period) / period;
  return 0.7 + 0.3 * math.cos(2 * math.pi * phase);
}

/// A placeholder block shown while content loads, instead of a spinner.
/// Decorative: the screen announces the loading itself. Still when the
/// platform asks for less motion.
class Skeleton extends StatefulWidget {
  const new({
    this.width,
    this.height = MonthraSpacing.x4,
    this.radius = MonthraRadii.smAll,
    super.key,
  });

  /// A round placeholder (an avatar, a category icon).
  const new circle({required double size, super.key})
    : width = size,
      height = size,
      radius = MonthraRadii.pillAll;

  /// Null fills the available width.
  final double? width;
  final double height;
  final BorderRadius radius;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_tick);
  double _opacity = 1;

  void _tick(Duration _) {
    final now = SchedulerBinding.instance.currentFrameTimeStamp;
    setState(() => _opacity = skeletonOpacity(now));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      if (_ticker.isActive) _ticker.stop();
      _opacity = 1;
    } else if (!_ticker.isActive) {
      _ticker.start();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = ShadTheme.of(context).colorScheme.skeleton;
    return ExcludeSemantics(
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color.withValues(alpha: color.a * _opacity),
            borderRadius: widget.radius,
          ),
        ),
      ),
    );
  }
}

/// Lines of text loading: full lines and a shorter last one.
class SkeletonText extends StatelessWidget {
  const new({
    this.lines = 3,
    this.lineHeight = MonthraSpacing.x3,
    this.lastLineWidthFactor = 0.6,
    super.key,
  }) : assert(lines > 0, 'at least one line');

  final int lines;
  final double lineHeight;
  final double lastLineWidthFactor;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (var i = 0; i < lines; i++) ...[
        if (i > 0) const SizedBox(height: MonthraSpacing.x2),
        FractionallySizedBox(
          widthFactor: i == lines - 1 && lines > 1 ? lastLineWidthFactor : 1,
          child: Skeleton(height: lineHeight),
        ),
      ],
    ],
  );
}
