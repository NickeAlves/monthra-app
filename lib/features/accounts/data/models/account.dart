import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:monthra/core/json/converters.dart';
import 'package:monthra/core/money/currency.dart';

part 'account.freezed.dart';
part 'account.g.dart';

/// What an account is (server `domain.AccountType`).
@JsonEnum(fieldRename: FieldRename.snake)
enum AccountType {
  checking,
  savings,
  creditCard,
  cash,
  brokerage,

  /// A type this build does not know yet.
  unknown;

  /// The types an account can be created with, in the form's order.
  static const List<AccountType> creatable = [
    checking,
    savings,
    creditCard,
    cash,
    brokerage,
  ];

  /// The API's name (`credit_card`).
  String get wire => switch (this) {
    creditCard => 'credit_card',
    _ => name,
  };
}

/// Where an account comes from.
@JsonEnum(fieldRename: FieldRename.snake)
enum AccountSource {
  manual,
  openFinance,

  /// A source this build does not know yet.
  unknown,
}

/// A credit card's statement cycle (`CardSettings` in the OpenAPI): the
/// day of the month the statement closes and the day it falls due (in a
/// shorter month, its last day), and the credit limit in minor units when
/// set.
@freezed
abstract class CardSettings with _$CardSettings {
  const factory({required int closingDay, required int dueDay, int? limit}) =
      _CardSettings;

  factory fromJson(Map<String, Object?> json) => _$CardSettingsFromJson(json);

  /// The first and last day of a month the API takes.
  static const int minDay = 1;
  static const int maxDay = 31;
}

/// An account or wallet of the caller (`Account` in the OpenAPI). Amounts
/// in minor units of [currency], which never changes.
@freezed
abstract class Account with _$Account {
  const factory({
    required String id,
    required String name,
    @JsonKey(unknownEnumValue: AccountType.unknown) required AccountType type,
    @CurrencyConverter() required Currency currency,

    /// The balance before any transaction (a card's debt below zero).
    required int initialBalance,

    /// The initial balance plus the transactions up to `asOf`.
    required int balance,

    /// The initial balance plus every transaction, future ones included.
    required int projectedBalance,

    /// A credit card's cycle; null for every other type.
    required CardSettings? card,
    @JsonKey(unknownEnumValue: AccountSource.unknown)
    required AccountSource source,
    required bool archived,
  }) = _Account;

  const new _();

  factory fromJson(Map<String, Object?> json) => _$AccountFromJson(json);

  /// A credit card with its cycle: one that has invoices.
  bool get isCard => type == AccountType.creditCard && card != null;

  /// What a card owes counting every purchase, the installments still to
  /// come included (as a bank blocks them on the limit); zero for a card
  /// in credit.
  int get cardDebt => projectedBalance < 0 ? -projectedBalance : 0;

  /// What is left of a card's limit (below zero past it); null without a
  /// limit.
  int? get availableLimit {
    final limit = card?.limit;
    return limit == null ? null : limit - cardDebt;
  }

  // The name may be personal data: never in a log (§6.6).
  @override
  String toString() => 'Account(id: $id, type: ${type.name})';
}

/// A new account (`AccountCreate` in the OpenAPI). [initialBalance] is in
/// minor units of [currency] (a card's debt below zero); [card] is required
/// for a credit card and refused for any other type.
@immutable
final class AccountDraft {
  const new({
    required this.name,
    required this.type,
    required this.currency,
    this.initialBalance = 0,
    this.card,
  });

  final String name;
  final AccountType type;
  final Currency currency;
  final int initialBalance;
  final CardSettings? card;

  Map<String, Object?> toJson() => {
    'name': name,
    'type': type.wire,
    'currency': currency.code,
    'initialBalance': initialBalance,
    if (card case final card?) 'card': card.toJson(),
  };

  @override
  String toString() => 'AccountDraft(type: ${type.name})';
}

/// A change to an account (`AccountPatch` in the OpenAPI): only what is
/// set goes out. [card] replaces the whole cycle (a null limit removes the
/// limit).
@immutable
final class AccountChanges {
  const new({this.name, this.initialBalance, this.card, this.archived});

  /// What the form's [name], [initialBalance] and [card] change on
  /// [before]; the card's cycle goes whole when any of it changed.
  factory between({
    required Account before,
    required String name,
    required int initialBalance,
    CardSettings? card,
  }) => AccountChanges(
    name: name == before.name ? null : name,
    initialBalance: initialBalance == before.initialBalance
        ? null
        : initialBalance,
    card: card == null || card == before.card ? null : card,
  );

  final String? name;
  final int? initialBalance;
  final CardSettings? card;
  final bool? archived;

  bool get isEmpty =>
      name == null &&
      initialBalance == null &&
      card == null &&
      archived == null;

  Map<String, Object?> toJson() => {
    'name': ?name,
    'initialBalance': ?initialBalance,
    if (card case final card?) 'card': card.toJson(),
    'archived': ?archived,
  };

  @override
  String toString() => 'AccountChanges(${toJson().keys.join(', ')})';
}
