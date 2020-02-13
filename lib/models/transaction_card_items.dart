import 'package:my_expenses/common/utils/transaction_utils.dart';
import 'package:my_expenses/models/transaction_item.dart';

class TransactionCardItems {
  final DateTime date;
  final String dateString;
  final List<TransactionItem> transactions;

  double get dayExpenses =>
      getTotalTransactionAmounts(transactions, onlyIncomes: false);

  double get dayIncomes =>
      getTotalTransactionAmounts(transactions, onlyIncomes: true);

  TransactionCardItems({
    this.date,
    this.dateString,
    this.transactions,
  });
}
