import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/features/dashboard/presentation/widgets/dashboard_layout.dart';
import 'package:monthra/l10n/l10n.dart';

/// The dashboard's shape while it loads: the figures and two sections, read
/// once as "loading".
class DashboardSkeleton extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final narrow = context.monthraBreakpoint == MonthraBreakpoint.mobile;
    final gap = narrow ? MonthraSpacing.x6 : MonthraSpacing.x8;
    return Semantics(
      container: true,
      liveRegion: true,
      label: context.l10n.dashboardLoading,
      child: ExcludeSemantics(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= dashboardTwoColumnsFrom;
            const figure = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skeleton(width: 96, height: MonthraSpacing.x3),
                SizedBox(height: MonthraSpacing.x3),
                Skeleton(width: 160, height: MonthraSpacing.x6),
                SizedBox(height: MonthraSpacing.x2),
                Skeleton(width: 120, height: MonthraSpacing.x3),
              ],
            );
            const section = MonthraSection(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Skeleton(width: 140),
                  SizedBox(height: MonthraSpacing.x6),
                  Skeleton(height: 200),
                ],
              ),
            );
            final figures = wide ? 4 : 2;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    for (var i = 0; i < figures; i++) ...[
                      if (i > 0) SizedBox(width: gap),
                      const Expanded(child: figure),
                    ],
                  ],
                ),
                SizedBox(height: gap),
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(flex: 7, child: section),
                      SizedBox(width: gap),
                      const Expanded(flex: 5, child: section),
                    ],
                  )
                else
                  section,
              ],
            );
          },
        ),
      ),
    );
  }
}
