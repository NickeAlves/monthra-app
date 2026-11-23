import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:monthra/core/config/env.dart';
import 'package:monthra/core/design_system/catalog/sample_categories.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/core/money/currency.dart';
import 'package:monthra/core/money/money_format.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// A living sheet of the design system, shown outside production only.
///
/// A development tool, not a product screen: its labels are fixed English
/// and its samples pt-BR, out of the i18n files on purpose.
class DesignSystemCatalog extends StatelessWidget {
  const new({required this.env, this.actions = const [], super.key});

  final Env env;

  /// Shown in the header: the app passes its theme and language pickers,
  /// to try both live.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final scheme = theme.colorScheme;
    final gutter = context.monthraBreakpoint == MonthraBreakpoint.mobile
        ? MonthraSpacing.x4
        : MonthraSpacing.x8;
    return ColoredBox(
      color: scheme.background,
      child: DefaultTextStyle(
        style: theme.textTheme.p.copyWith(color: scheme.foreground),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: gutter,
              vertical: MonthraSpacing.x8,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(env: env, actions: actions),
                    const _Section(title: 'Typography', child: _Typography()),
                    const _Section(title: 'Color roles', child: _Palette()),
                    const _Section(title: 'Controls', child: _Controls()),
                    const _Section(title: 'Cards', child: _Cards()),
                    const _Section(title: 'Amounts', child: _Amounts()),
                    const _Section(title: 'Categories', child: _Categories()),
                    const _Section(title: 'Charts', child: _Charts()),
                    const _Section(title: 'States', child: _States()),
                    const _Section(title: 'Pages and toasts', child: _Pages()),
                    const _Section(
                      title: 'Sub-page and QR code',
                      child: _SubPage(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const new({required this.env, required this.actions});

  final Env env;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final symbol = theme.brightness == Brightness.dark
        ? 'assets/brand/monthra-simbolo-branco.svg'
        : 'assets/brand/monthra-simbolo.svg';
    return Wrap(
      spacing: MonthraSpacing.x4,
      runSpacing: MonthraSpacing.x4,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Wrap(
          spacing: MonthraSpacing.x3,
          runSpacing: MonthraSpacing.x2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SvgPicture.asset(symbol, width: 32, height: 32),
            Text(
              'Design system',
              style: theme.textTheme.h3.copyWith(
                color: theme.colorScheme.foreground,
              ),
            ),
            ShadBadge.secondary(child: Text(env.appEnv.name)),
          ],
        ),
        Wrap(
          spacing: MonthraSpacing.x3,
          runSpacing: MonthraSpacing.x2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: actions,
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const new({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: MonthraSpacing.x12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              style: theme.textTheme.h4.copyWith(
                color: theme.colorScheme.foreground,
              ),
            ),
          ),
          const SizedBox(height: MonthraSpacing.x4),
          child,
        ],
      ),
    );
  }
}

class _Typography extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final text = theme.textTheme;
    final scheme = theme.colorScheme;
    final styles = <(String, TextStyle, Color)>[
      ('h1Large', text.h1Large, scheme.foreground),
      ('h1', text.h1, scheme.foreground),
      ('h2', text.h2, scheme.foreground),
      ('h3', text.h3, scheme.foreground),
      ('h4', text.h4, scheme.foreground),
      ('lead', text.lead, scheme.mutedForeground),
      ('large', text.large, scheme.foreground),
      ('p', text.p, scheme.foreground),
      ('small', text.small, scheme.foreground),
      ('muted', text.muted, scheme.mutedForeground),
      ('label', text.label, scheme.foreground),
      ('caption', text.caption, scheme.mutedForeground),
    ];
    return MonthraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (name, style, color) in styles) ...[
            Text(
              '$name · ${style.fontSize!.round()}/${style.fontWeight!.value}',
              style: text.caption.copyWith(color: scheme.mutedForeground),
            ),
            Text('Orçamento de março', style: style.copyWith(color: color)),
            const SizedBox(height: MonthraSpacing.x3),
          ],
        ],
      ),
    );
  }
}

String _hex(Color color) =>
    '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}'
        .toUpperCase();

String _ratio(Color a, Color b) =>
    '${contrastRatio(a, b).toStringAsFixed(1)}:1';

class _Palette extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final scheme = theme.colorScheme;
    final roles = <(String, Color)>[
      ('background', scheme.background),
      ('card', scheme.card),
      ('foreground', scheme.foreground),
      ('mutedForeground', scheme.mutedForeground),
      ('primary', scheme.primary),
      ('accentText', scheme.accentText),
      ('ring', scheme.ring),
      ('border', scheme.border),
      ('income', scheme.income),
      ('expense', scheme.expense),
      ('warning', scheme.warning),
      ('destructive', scheme.destructive),
    ];
    return Wrap(
      spacing: MonthraSpacing.x3,
      runSpacing: MonthraSpacing.x3,
      children: [
        for (final (name, color) in roles)
          SizedBox(
            width: 148,
            child: MonthraCard(
              padding: const EdgeInsets.all(MonthraSpacing.x3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: MonthraSpacing.x10,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: MonthraRadii.smAll,
                      border: Border.all(color: scheme.border),
                    ),
                  ),
                  const SizedBox(height: MonthraSpacing.x2),
                  Text(name, style: theme.textTheme.label),
                  Text(
                    '${_hex(color)} · ${_ratio(color, scheme.background)}',
                    style: theme.textTheme.caption.copyWith(
                      color: scheme.mutedForeground,
                      fontFeatures: MonthraTypography.tabularFigures,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Controls extends StatefulWidget {
  const new();

  @override
  State<_Controls> createState() => _ControlsState();
}

class _ControlsState extends State<_Controls> {
  bool _alerts = true;
  bool _remember = false;

  static const _accounts = {
    'checking': 'Conta corrente',
    'card': 'Cartão de crédito',
    'cash': 'Dinheiro',
  };

  @override
  Widget build(BuildContext context) {
    void noop() {}
    return MonthraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: MonthraSpacing.x2,
            runSpacing: MonthraSpacing.x2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ShadButton(
                onPressed: noop,
                leading: const Icon(LucideIcons.plus),
                child: const ButtonLabel('Nova transação'),
              ),
              ShadButton.secondary(
                onPressed: noop,
                child: const ButtonLabel('Secondary'),
              ),
              ShadButton.outline(
                onPressed: noop,
                child: const ButtonLabel('Outline'),
              ),
              ShadButton.ghost(
                onPressed: noop,
                child: const ButtonLabel('Ghost'),
              ),
              ShadButton.destructive(
                onPressed: noop,
                child: const ButtonLabel('Excluir'),
              ),
              ShadButton.link(
                onPressed: noop,
                child: const ButtonLabel('Link'),
              ),
              const ShadButton(enabled: false, child: ButtonLabel('Disabled')),
              // An icon-only button reads its icon's label.
              ShadIconButton.outline(
                onPressed: noop,
                icon: const Icon(
                  LucideIcons.slidersHorizontal,
                  semanticLabel: 'Filtros',
                ),
              ),
            ],
          ),
          const SizedBox(height: MonthraSpacing.x3),
          Wrap(
            spacing: MonthraSpacing.x2,
            runSpacing: MonthraSpacing.x2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // 36 px: pointer layouts only, under the 44 px touch target.
              if (context.monthraBreakpoint != MonthraBreakpoint.mobile)
                ShadButton(
                  size: ShadButtonSize.sm,
                  onPressed: noop,
                  child: const ButtonLabel('Small'),
                ),
              ShadButton(onPressed: noop, child: const ButtonLabel('Regular')),
              ShadButton(
                size: ShadButtonSize.lg,
                onPressed: noop,
                child: const ButtonLabel('Large'),
              ),
              const ShadBadge(child: Text('Badge')),
              const ShadBadge.secondary(child: Text('Secondary')),
              const ShadBadge.outline(child: Text('Outline')),
              const ShadBadge.destructive(child: Text('Destructive')),
            ],
          ),
          const SizedBox(height: MonthraSpacing.x6),
          const ShadInput(placeholder: Text('Descrição')),
          const SizedBox(height: MonthraSpacing.x3),
          ShadSelect<String>(
            placeholder: const Text('Conta'),
            minWidth: 240,
            options: [
              for (final entry in _accounts.entries)
                ShadOption(value: entry.key, child: Text(entry.value)),
            ],
            selectedOptionBuilder: (context, value) =>
                Text(_accounts[value] ?? value),
          ),
          const SizedBox(height: MonthraSpacing.x4),
          ShadSwitch(
            value: _alerts,
            onChanged: (value) => setState(() => _alerts = value),
            label: const Text('Alertas de orçamento'),
          ),
          const SizedBox(height: MonthraSpacing.x3),
          ShadCheckbox(
            value: _remember,
            onChanged: (value) => setState(() => _remember = value),
            label: const Text('Lembrar este dispositivo'),
          ),
        ],
      ),
    );
  }
}

void _toast(
  BuildContext context,
  String message, {
  String? description,
  bool destructive = false,
}) => showMonthraToast(
  context,
  title: message,
  description: description,
  destructive: destructive,
  closeLabel: 'Close',
);

class _Cards extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Wrap(
      spacing: MonthraSpacing.x4,
      runSpacing: MonthraSpacing.x4,
      children: [
        const SizedBox(
          width: 300,
          child: MonthraCard(
            title: Text('Saldo'),
            description: Text('Todas as contas em reais'),
            child: Padding(
              padding: EdgeInsets.only(top: MonthraSpacing.x4),
              child: AmountText(
                1284590,
                currency: Currency.brl,
                size: AmountSize.display,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 300,
          child: MonthraCard(
            semanticLabel: 'Nubank, cartão de crédito',
            onTap: () => _toast(context, 'Card tapped'),
            title: const Text('Nubank'),
            description: const Text('Cartão de crédito · fecha dia 3'),
            trailing: Icon(
              LucideIcons.chevronRight,
              size: 16,
              color: theme.colorScheme.mutedForeground,
            ),
            child: const Padding(
              padding: EdgeInsets.only(top: MonthraSpacing.x4),
              child: AmountText(
                -245090,
                currency: Currency.brl,
                size: AmountSize.title,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Amounts extends StatefulWidget {
  const new();

  @override
  State<_Amounts> createState() => _AmountsState();
}

class _AmountsState extends State<_Amounts> {
  final _random = math.Random();
  int _total = 1284590;

  static const _locales = [
    Locale('pt', 'BR'),
    Locale('es', 'ES'),
    Locale('en', 'US'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final caption = theme.textTheme.caption.copyWith(
      color: theme.colorScheme.mutedForeground,
    );
    return MonthraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final locale in _locales) ...[
            Text(locale.toLanguageTag(), style: caption),
            Wrap(
              spacing: MonthraSpacing.x6,
              children: [
                for (final currency in Currency.values)
                  AmountText(123456, currency: currency, locale: locale),
                AmountText(-123456, currency: Currency.brl, locale: locale),
              ],
            ),
            const SizedBox(height: MonthraSpacing.x3),
          ],
          Text('Kinds', style: caption),
          const Wrap(
            spacing: MonthraSpacing.x6,
            children: [
              AmountText(
                450000,
                currency: Currency.brl,
                kind: AmountKind.income,
              ),
              AmountText(
                12990,
                currency: Currency.brl,
                kind: AmountKind.expense,
              ),
              AmountText(-3450, currency: Currency.brl),
            ],
          ),
          const SizedBox(height: MonthraSpacing.x3),
          Text('Sizes', style: caption),
          const Wrap(
            spacing: MonthraSpacing.x6,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              AmountText(
                1284590,
                currency: Currency.brl,
                size: AmountSize.display,
              ),
              AmountText(
                1284590,
                currency: Currency.brl,
                size: AmountSize.title,
              ),
              AmountText(1284590, currency: Currency.brl),
              AmountText(
                1284590,
                currency: Currency.brl,
                size: AmountSize.small,
              ),
            ],
          ),
          const SizedBox(height: MonthraSpacing.x3),
          Text('Animated total', style: caption),
          Row(
            children: [
              Expanded(
                child: AmountText(
                  _total,
                  currency: Currency.brl,
                  size: AmountSize.display,
                  animate: true,
                ),
              ),
              ShadButton.outline(
                onPressed: () =>
                    setState(() => _total = _random.nextInt(5000000) - 1000000),
                leading: const Icon(LucideIcons.shuffle),
                child: const ButtonLabel('Shuffle'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Categories extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) => MonthraCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: MonthraSpacing.x2,
          runSpacing: MonthraSpacing.x2,
          children: [
            for (final c in sampleCategories)
              CategoryBadge(icon: c.icon, color: c.color, label: c.name),
          ],
        ),
        const SizedBox(height: MonthraSpacing.x6),
        Wrap(
          spacing: MonthraSpacing.x3,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final size in CategoryIconSize.values)
              CategoryIcon(icon: 'shopping-cart', color: '#22C55E', size: size),
            const CategoryIcon(icon: 'unknown-icon', color: 'invalid'),
          ],
        ),
      ],
    ),
  );
}

class _Charts extends StatelessWidget {
  const new();

  // Twelve months of income and expense (in cents) and the net worth, the
  // last two months still to come (no net worth).
  static const _income = [
    820000, 845000, 800000, 830000, 900000, 850000, //
    870000, 820000, 905000, 850000, 850000, 850000,
  ];
  static const _expense = [
    410000, 395000, 450000, 380000, 520000, 401000, //
    430000, 398000, 470000, 412345, 0, 0,
  ];
  static const List<int?> _worth = [
    1520000, 1610000, 1590000, 1700000, 1760000, 1820000, //
    1850000, 1880000, 1910000, 1938321, null, null,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final scheme = theme.colorScheme;
    final locale = Localizations.localeOf(context);
    final months = DateFormat.MMM(locale.toLanguageTag());
    final labels = [
      for (var i = 0; i < 12; i++) months.format(DateTime(2026, i + 1)),
    ];
    String axis(double v) => MoneyFormat.compact(v.round(), locale);
    String value(double v) =>
        MoneyFormat.format(v.round(), Currency.brl, locale);
    final caption = theme.textTheme.caption.copyWith(
      color: scheme.mutedForeground,
    );
    return MonthraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Donut (six parts, then empty)', style: caption),
          const SizedBox(height: MonthraSpacing.x3),
          Wrap(
            spacing: MonthraSpacing.x6,
            runSpacing: MonthraSpacing.x4,
            children: [
              MonthraDonutChart(
                semanticLabel: 'Expenses by category',
                slices: [
                  for (final (i, c) in sampleCategories.take(5).indexed)
                    DonutSlice(
                      value: (5 - i) * 10.0,
                      color: parseHexColor(c.color)!,
                    ),
                  DonutSlice(value: 8, color: scheme.mutedForeground),
                ],
                center: const AmountText(
                  412345,
                  currency: Currency.brl,
                  size: AmountSize.small,
                  alignment: Alignment.center,
                ),
              ),
              const MonthraDonutChart(semanticLabel: 'No expenses', slices: []),
            ],
          ),
          const SizedBox(height: MonthraSpacing.x6),
          Text('Bars (October highlighted)', style: caption),
          const SizedBox(height: MonthraSpacing.x3),
          MonthraBarChart(
            semanticLabel: 'Income and expenses, 12 months',
            labels: labels,
            highlight: 9,
            formatAxis: axis,
            formatValue: value,
            series: [
              BarSeries(
                name: 'Income',
                color: scheme.income,
                values: [for (final v in _income) v.toDouble()],
              ),
              BarSeries(
                name: 'Expenses',
                color: scheme.expense,
                values: [for (final v in _expense) v.toDouble()],
              ),
            ],
          ),
          const SizedBox(height: MonthraSpacing.x6),
          Text('Line (the months to come have no point)', style: caption),
          const SizedBox(height: MonthraSpacing.x3),
          MonthraLineChart(
            semanticLabel: 'Net worth, 12 months',
            labels: labels,
            values: [for (final v in _worth) v?.toDouble()],
            color: scheme.accentText,
            highlight: 9,
            formatAxis: axis,
            formatValue: value,
          ),
        ],
      ),
    );
  }
}

class _States extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: MonthraSpacing.x4,
    runSpacing: MonthraSpacing.x4,
    children: [
      SizedBox(
        width: 300,
        child: MonthraCard(
          child: EmptyState(
            title: 'Nenhuma transação ainda',
            message: 'As transações do mês aparecem aqui.',
            icon: LucideIcons.receipt,
            action: ShadButton(
              onPressed: () => _toast(context, 'Create tapped'),
              leading: const Icon(LucideIcons.plus),
              child: const ButtonLabel('Nova transação'),
            ),
          ),
        ),
      ),
      SizedBox(
        width: 300,
        child: MonthraCard(
          child: ErrorState(
            title: 'Não foi possível carregar',
            message: 'Verifique sua conexão e tente de novo.',
            retryLabel: 'Tentar de novo',
            onRetry: () => _toast(context, 'Retry tapped'),
          ),
        ),
      ),
      SizedBox(
        width: 300,
        child: MonthraCard(
          child: Column(
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(height: MonthraSpacing.x4),
                const Row(
                  children: [
                    Skeleton.circle(size: 36),
                    SizedBox(width: MonthraSpacing.x3),
                    Expanded(child: SkeletonText(lines: 2)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    ],
  );
}

/// An authenticator app URI with a made-up secret.
const String _sampleOtpauth =
    'otpauth://totp/Monthra:ana%40example.com?algorithm=SHA1&digits=6'
    '&issuer=Monthra&period=30&secret=JBSWY3DPEHPK3PXPJBSWY3DPEHPK3PXP';

/// A page under another one (its way back above the title) holding a QR
/// code, in a frame of its own: [MonthraPage] scrolls by itself.
class _SubPage extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) => MonthraCard(
    child: SizedBox(
      height: 520,
      child: MonthraPage(
        title: 'Ativar a verificação',
        description: 'Escaneie o código com o app autenticador.',
        back: MonthraPageBack(
          label: 'Configurações',
          onPressed: () => _toast(context, 'Back tapped'),
        ),
        child: const Center(
          child: QrCodeView(
            data: _sampleOtpauth,
            semanticLabel: 'QR code to add Monthra (sample)',
          ),
        ),
      ),
    ),
  );
}

class _Pages extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) => MonthraCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MonthraPageHeader(
          title: 'Configurações',
          description: 'Perfil, preferências e segurança da conta.',
          actions: [
            ShadButton.outline(
              onPressed: () => _toast(
                context,
                'Nome salvo.',
                description: 'Aparece em todos os dispositivos.',
              ),
              leading: const Icon(LucideIcons.bell),
              child: const ButtonLabel('Toast'),
            ),
            ShadButton.outline(
              onPressed: () async {
                final confirmed = await showMonthraConfirm(
                  context,
                  title: 'Encerrar as outras sessões?',
                  description:
                      'Os outros dispositivos vão pedir para entrar de novo.',
                  confirmLabel: 'Encerrar sessões',
                  cancelLabel: 'Cancelar',
                  barrierLabel: 'Fechar',
                  destructive: true,
                );
                if (context.mounted) {
                  _toast(context, confirmed ? 'Confirmed' : 'Cancelled');
                }
              },
              leading: const Icon(LucideIcons.messageSquareWarning),
              child: const ButtonLabel('Confirm'),
            ),
            ShadButton.destructive(
              onPressed: () => _toast(
                context,
                'Sua alteração não foi salva',
                description: 'Verifique sua conexão e tente de novo.',
                destructive: true,
              ),
              leading: const Icon(LucideIcons.circleAlert),
              child: const ButtonLabel('Error toast'),
            ),
          ],
        ),
      ],
    ),
  );
}
