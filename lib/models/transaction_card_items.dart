import 'package:equatable/equatable.dart';

import '../common/utils/transaction_utils.dart';
import 'transaction_item.dart';

class TransactionCardItems extends Equatable {
  final DateTime date;
  final String dateString;
  final List<TransactionItem> transactions;

  @override
  List<Object> get props => [date, dateString, transactions];

  double get dayExpenses => TransactionUtils.getTotalTransactionAmounts(
        transactions,
        onlyIncomes: false,
      );

  double get dayIncomes => TransactionUtils.getTotalTransactionAmounts(
        transactions,
        onlyIncomes: true,
      );

  const TransactionCardItems({
    this.date,
    this.dateString,
    this.transactions,
  });
}
