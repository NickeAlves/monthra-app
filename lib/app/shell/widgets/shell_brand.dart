import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// The brand at the top of the sidebar: the logo, or the symbol alone in
/// the collapsed one; white on the dark theme.
class ShellBrand extends StatelessWidget {
  const new({this.compact = false, super.key});

  final bool compact;

  static const double logoHeight = 32;
  static const double symbolSize = 28;

  @override
  Widget build(BuildContext context) {
    final dark = ShadTheme.of(context).brightness == Brightness.dark;
    final asset = compact
        ? (dark
              ? 'assets/brand/monthra-simbolo-branco.svg'
              : 'assets/brand/monthra-simbolo.svg')
        : (dark
              ? 'assets/brand/monthra-logo-branco.svg'
              : 'assets/brand/monthra-logo.svg');
    return Semantics(
      // The brand name, the same in every language.
      label: 'Monthra',
      image: true,
      child: SvgPicture.asset(
        asset,
        height: compact ? symbolSize : logoHeight,
        width: compact ? symbolSize : null,
      ),
    );
  }
}
