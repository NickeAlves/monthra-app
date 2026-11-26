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
  unknown,
}

/// Where an account comes from.
@JsonEnum(fieldRename: FieldRename.snake)
enum AccountSource {
  manual,
  openFinance,

  /// A source this build does not know yet.
  unknown,
}

/// An account or wallet of the caller (`GET /accounts`, `Account` in the
/// OpenAPI), the fields the app reads so far. Amounts in minor units of
/// [currency], which never changes.
@freezed
abstract class Account with _$Account {
  const factory({
    required String id,
    required String name,
    @JsonKey(unknownEnumValue: AccountType.unknown) required AccountType type,
    @CurrencyConverter() required Currency currency,

    /// The initial balance plus the transactions up to `asOf`.
    required int balance,

    /// The initial balance plus every transaction, future ones included.
    required int projectedBalance,
    @JsonKey(unknownEnumValue: AccountSource.unknown)
    required AccountSource source,
    required bool archived,
  }) = _Account;

  const new _();

  factory fromJson(Map<String, Object?> json) => _$AccountFromJson(json);

  // The name may be personal data: never in a log (§6.6).
  @override
  String toString() => 'Account(id: $id, type: ${type.name})';
}
