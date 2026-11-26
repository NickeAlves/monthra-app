import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/features/accounts/data/models/account.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../settings/security_test_helpers.dart' show expectGuidelines;
import 'accounts_test_helpers.dart';

const tablet = Size(800, 1100);

/// The tap target, label and contrast guidelines on the accounts pages and
/// the account form at the three sizes in both themes, and twice the text
/// size without an overflow.
void main() {
  const sizes = [('phone', phone), ('tablet', tablet), ('desktop', desktop)];

  for (final brightness in Brightness.values) {
    for (final (name, size) in sizes) {
      group('${brightness.name} $name', () {
        testWidgets('the list, archived ones shown', (tester) async {
          await pumpAccounts(tester, size: size, brightness: brightness);
          await tester.tapLabel(pt.accountsShowArchived(1));
          await expectGuidelines(tester, phone: name == 'phone');
        });

        testWidgets("a card's form", (tester) async {
          await pumpAccounts(tester, size: size, brightness: brightness);
          await tester.tapLabel(pt.accountsNew);
          await tester.pick(
            find.byType(ShadSelect<AccountType>),
            pt.accountTypeCreditCard,
          );
          await expectGuidelines(tester, phone: name == 'phone');
        });

        testWidgets("a card's page", (tester) async {
          await pumpAccounts(
            tester,
            size: size,
            brightness: brightness,
            location: '/accounts/acc-card',
          );
          await expectGuidelines(tester, phone: name == 'phone');
        });
      });
    }
  }

  for (final (name, size) in sizes) {
    testWidgets('copes with twice the text size on a $name', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpAccounts(tester, size: size);
      expect(tester.takeException(), isNull);
      await tester.tapLabel(pt.accountsNew);
      await tester.pick(
        find.byType(ShadSelect<AccountType>),
        pt.accountTypeCreditCard,
      );
      expect(tester.takeException(), isNull);
      await tester.tapLabel(pt.appCancel);
      await pumpAccounts(tester, size: size, location: '/accounts/acc-card');
      expect(tester.takeException(), isNull);
    });
  }
}
