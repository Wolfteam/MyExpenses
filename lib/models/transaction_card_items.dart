import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/common/utils/transaction_utils.dart';

import 'transaction_item.dart';

part 'transaction_card_items.freezed.dart';

@freezed
class TransactionCardItems with _$TransactionCardItems {
  double get dayExpenses => TransactionUtils.getTotalTransactionAmounts(transactions);

  double get dayIncomes => TransactionUtils.getTotalTransactionAmounts(transactions, onlyIncomes: true);

  const TransactionCardItems._();

  const factory TransactionCardItems({
    required DateTime date,
    required String dateString,
    required List<TransactionItem> transactions,
  }) = _TransactionCardItems;
}
