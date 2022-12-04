import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/domain/models/transaction_item.dart';
import 'package:my_expenses/domain/utils/transaction_utils.dart';

part 'transaction_card_items.freezed.dart';

@freezed
class TransactionCardItems with _$TransactionCardItems {
  double get dayExpenses => TransactionUtils.getTotalTransactionAmounts(transactions);

  double get dayIncomes => TransactionUtils.getTotalTransactionAmounts(transactions, onlyIncomes: true);

  const factory TransactionCardItems({
    required DateTime date,
    required String dateString,
    required List<TransactionItem> transactions,
  }) = _TransactionCardItems;

  const TransactionCardItems._();
}
