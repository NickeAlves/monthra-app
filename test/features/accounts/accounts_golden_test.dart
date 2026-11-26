import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/app/app.dart';
import 'package:monthra/features/accounts/data/models/account.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../helpers/golden.dart';
import 'accounts_test_helpers.dart';

/// Goldens (pt-BR, motion off) of the accounts page, a card's page and the
/// form of a new card, on a desktop and a phone, in both themes.
void main() {
  const scenes = [
    ('accounts_desktop', Size(1280, 1000), '/accounts', false),
    ('accounts_phone', Size(390, 1300), '/accounts', false),
    ('account_card_desktop', Size(1280, 1700), '/accounts/acc-card', false),
    ('account_card_phone', Size(390, 2500), '/accounts/acc-card', false),
    ('account_form_desktop', Size(1280, 1000), '/accounts', true),
    ('account_form_phone', Size(390, 1100), '/accounts', true),
  ];

  for (final (name, size, location, form) in scenes) {
    group(name, () {
      for (final brightness in Brightness.values) {
        testWidgets(brightness.name, tags: ['golden'], (tester) async {
          await pumpAccounts(
            tester,
            size: size,
            brightness: brightness,
            location: location,
          );
          if (form) {
            await tester.tapLabel(pt.accountsNew);
            await tester.type(pt.accountFormName, 'Cartão Verde');
            await tester.pick(
              find.byType(ShadSelect<AccountType>),
              pt.accountTypeCreditCard,
            );
            await tester.type(pt.accountFormCardDebt, '25000');
            await tester.pick(
              find.byType(ShadSelect<int>).at(0),
              pt.accountFormDay(3),
            );
            await tester.pick(
              find.byType(ShadSelect<int>).at(1),
              pt.accountFormDay(10),
            );
            // The caret blinks: take it away.
            FocusManager.instance.primaryFocus?.unfocus();
            await tester.settle();
          }
          expect(tester.takeException(), isNull);

          if (!goldensRunHere) {
            markTestSkipped('image comparison runs on Linux only (see README)');
            return;
          }
          await expectLater(
            find.byType(MonthraApp),
            matchesGoldenFile('goldens/${name}_${brightness.name}.png'),
          );
        });
      }
    });
  }
}
