import '../../models/transaction_item.dart';

double getTotalTransactionAmounts(
  List<TransactionItem> transactions, {
  bool onlyIncomes,
}) {
  return transactions
      .where((t) => t.category.isAnIncome == onlyIncomes)
      .map((t) => t.amount)
      .fold(0, (t1, t2) => t1 + t2);
}
