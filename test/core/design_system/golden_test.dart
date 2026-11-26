import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/catalog/sample_categories.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/core/money/currency.dart';
import 'package:monthra/core/money/money_format.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../helpers/golden.dart';

/// Every component in both themes (§7.6). Rendered and compared on Linux
/// only; see "Golden tests" in the README to update them.
void main() {
  goldenTest('typography', size: const Size(480, 640), () {
    return Builder(
      builder: (context) {
        final theme = ShadTheme.of(context);
        final text = theme.textTheme;
        final scheme = theme.colorScheme;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (style, color) in [
              (text.h1Large, scheme.foreground),
              (text.h1, scheme.foreground),
              (text.h2, scheme.foreground),
              (text.h3, scheme.foreground),
              (text.h4, scheme.foreground),
              (text.lead, scheme.mutedForeground),
              (text.large, scheme.foreground),
              (text.p, scheme.foreground),
              (text.label, scheme.foreground),
              (text.muted, scheme.mutedForeground),
              (text.caption, scheme.mutedForeground),
            ])
              Text('Orçamento de março', style: style.copyWith(color: color)),
          ],
        );
      },
    );
  });

  goldenTest('color_roles', size: const Size(480, 200), () {
    return Builder(
      builder: (context) {
        final scheme = ShadTheme.of(context).colorScheme;
        return Wrap(
          spacing: MonthraSpacing.x2,
          runSpacing: MonthraSpacing.x2,
          children: [
            for (final color in [
              scheme.background,
              scheme.card,
              scheme.foreground,
              scheme.mutedForeground,
              scheme.primary,
              scheme.accentText,
              scheme.ring,
              scheme.border,
              scheme.income,
              scheme.expense,
              scheme.warning,
              scheme.destructive,
            ])
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: MonthraRadii.smAll,
                  border: Border.all(color: scheme.border),
                ),
              ),
          ],
        );
      },
    );
  });

  goldenTest('controls', size: const Size(480, 420), () {
    void noop() {}
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: MonthraSpacing.x2,
          runSpacing: MonthraSpacing.x2,
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
            ShadButton.link(onPressed: noop, child: const ButtonLabel('Link')),
            const ShadButton(enabled: false, child: ButtonLabel('Disabled')),
          ],
        ),
        const SizedBox(height: MonthraSpacing.x3),
        const Wrap(
          spacing: MonthraSpacing.x2,
          children: [
            ShadBadge(child: Text('Badge')),
            ShadBadge.secondary(child: Text('Secondary')),
            ShadBadge.outline(child: Text('Outline')),
            ShadBadge.destructive(child: Text('Destructive')),
          ],
        ),
        const SizedBox(height: MonthraSpacing.x4),
        const ShadInput(placeholder: Text('Descrição')),
        const SizedBox(height: MonthraSpacing.x2),
        ShadSwitch(
          value: true,
          onChanged: (_) {},
          label: const Text('Alertas de orçamento'),
        ),
        ShadCheckbox(
          value: true,
          onChanged: (_) {},
          label: const Text('Lembrar este dispositivo'),
        ),
      ],
    );
  });

  goldenTest(
    'cards',
    size: const Size(480, 360),
    () => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const MonthraCard(
          title: Text('Saldo'),
          description: Text('Todas as contas em reais'),
          child: Padding(
            padding: EdgeInsets.only(top: MonthraSpacing.x4),
            child: AmountText(
              1284590,
              currency: Currency.brl,
              size: AmountSize.display,
              locale: Locale('pt', 'BR'),
            ),
          ),
        ),
        const SizedBox(height: MonthraSpacing.x4),
        MonthraCard(
          onTap: () {},
          title: const Text('Nubank'),
          description: const Text('Cartão de crédito'),
          child: const Padding(
            padding: EdgeInsets.only(top: MonthraSpacing.x4),
            child: AmountText(
              -245090,
              currency: Currency.brl,
              size: AmountSize.title,
              locale: Locale('pt', 'BR'),
            ),
          ),
        ),
      ],
    ),
    // The tappable card with its keyboard focus ring.
    setup: (tester) async {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    },
  );

  goldenTest('amounts', size: const Size(480, 300), () {
    const locales = [
      Locale('pt', 'BR'),
      Locale('es', 'ES'),
      Locale('en', 'US'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final locale in locales)
          Wrap(
            spacing: MonthraSpacing.x4,
            children: [
              AmountText(123456, currency: Currency.brl, locale: locale),
              AmountText(123456, currency: Currency.usd, locale: locale),
              AmountText(123456, currency: Currency.eur, locale: locale),
              AmountText(-123456, currency: Currency.brl, locale: locale),
            ],
          ),
        const SizedBox(height: MonthraSpacing.x4),
        const Wrap(
          spacing: MonthraSpacing.x4,
          children: [
            AmountText(
              450000,
              currency: Currency.brl,
              kind: AmountKind.income,
              locale: Locale('pt', 'BR'),
            ),
            AmountText(
              12990,
              currency: Currency.brl,
              kind: AmountKind.expense,
              locale: Locale('pt', 'BR'),
            ),
          ],
        ),
        const SizedBox(height: MonthraSpacing.x4),
        const AmountText(
          1284590,
          currency: Currency.brl,
          size: AmountSize.display,
          locale: Locale('pt', 'BR'),
        ),
        const AmountText(
          1284590,
          currency: Currency.brl,
          size: AmountSize.title,
          locale: Locale('pt', 'BR'),
        ),
        const AmountText(
          1284590,
          currency: Currency.brl,
          size: AmountSize.small,
          locale: Locale('pt', 'BR'),
        ),
      ],
    );
  });

  goldenTest(
    'categories',
    size: const Size(480, 420),
    () => Column(
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
        const SizedBox(height: MonthraSpacing.x4),
        Wrap(
          spacing: MonthraSpacing.x2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final size in CategoryIconSize.values)
              CategoryIcon(icon: 'utensils', color: '#F97316', size: size),
            const CategoryIcon(icon: 'unknown-icon', color: 'invalid'),
          ],
        ),
      ],
    ),
  );

  goldenTest(
    'states',
    size: const Size(480, 680),
    () => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MonthraCard(
          child: EmptyState(
            title: 'Nenhuma transação ainda',
            message: 'As transações do mês aparecem aqui.',
            icon: LucideIcons.receipt,
            action: ShadButton(
              onPressed: () {},
              leading: const Icon(LucideIcons.plus),
              child: const ButtonLabel('Nova transação'),
            ),
          ),
        ),
        const SizedBox(height: MonthraSpacing.x4),
        MonthraCard(
          child: ErrorState(
            title: 'Não foi possível carregar',
            message: 'Verifique sua conexão e tente de novo.',
            retryLabel: 'Tentar de novo',
            onRetry: () {},
          ),
        ),
      ],
    ),
  );

  goldenTest(
    'skeleton',
    size: const Size(480, 176),
    () => MonthraCard(
      child: Column(
        children: [
          for (var i = 0; i < 2; i++) ...[
            if (i > 0) const SizedBox(height: MonthraSpacing.x4),
            const Row(
              children: [
                Skeleton.circle(size: 36),
                SizedBox(width: MonthraSpacing.x3),
                Expanded(child: SkeletonText(lines: 2)),
                SizedBox(width: MonthraSpacing.x6),
                Skeleton(width: 72),
              ],
            ),
          ],
        ],
      ),
    ),
  );

  goldenTest('charts', size: const Size(480, 720), () {
    return Builder(
      builder: (context) {
        final scheme = ShadTheme.of(context).colorScheme;
        const labels = [
          'dez.', 'jan.', 'fev.', 'mar.', 'abr.', 'mai.', //
          'jun.', 'jul.', 'ago.', 'set.', 'out.', 'nov.',
        ];
        String axis(double v) => MoneyFormat.compact(v.round(), _ptBR);
        String value(double v) =>
            MoneyFormat.format(v.round(), Currency.brl, _ptBR);
        return MonthraCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  MonthraDonutChart(
                    semanticLabel: 'Gastos por categoria',
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
                  const SizedBox(width: MonthraSpacing.x6),
                  const MonthraDonutChart(
                    semanticLabel: 'Nenhum gasto',
                    slices: [],
                    size: 96,
                    thickness: 10,
                  ),
                ],
              ),
              const SizedBox(height: MonthraSpacing.x6),
              MonthraBarChart(
                semanticLabel: 'Entradas e saídas',
                labels: labels,
                highlight: 11,
                formatAxis: axis,
                formatValue: value,
                series: [
                  BarSeries(
                    name: 'Entradas',
                    color: scheme.income,
                    values: [
                      for (var i = 0; i < 12; i++) 800000.0 + (i % 3) * 25000,
                    ],
                  ),
                  BarSeries(
                    name: 'Saídas',
                    color: scheme.expense,
                    values: [
                      for (var i = 0; i < 12; i++) 350000.0 + (i % 4) * 30000,
                    ],
                  ),
                ],
              ),
              const SizedBox(height: MonthraSpacing.x6),
              MonthraLineChart(
                semanticLabel: 'Patrimônio',
                labels: labels,
                values: [
                  for (var i = 0; i < 12; i++)
                    if (i > 9) null else 1500000.0 + i * 45000,
                ],
                color: scheme.accentText,
                highlight: 9,
                formatAxis: axis,
                formatValue: value,
              ),
            ],
          ),
        );
      },
    );
  });
}

const _ptBR = Locale('pt', 'BR');
