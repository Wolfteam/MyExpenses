import '../models/transaction_item.dart';

abstract class TransactionsDao {
  Future<List<TransactionItem>> getAllTransactions(DateTime from, DateTime to);

  Future<TransactionItem> saveTransaction(TransactionItem transaction);

  Future<bool> deleteTransaction(int id);

  Future<List<TransactionItem>> getAllParentTransactions();

  Future<List<TransactionItem>> getAllParentTransactionsUntil(DateTime until);

  Future<List<TransactionItem>> getAllChildTransactions(
    int parentId,
    DateTime from,
    DateTime to,
  );

  Future<void> checkAndSaveRecurringTransactions(
    TransactionItem parent,
    DateTime nextRecurringDate,
    List<DateTime> periods,
  );

  Future<TransactionItem> getTransaction(int id);

  Future<bool> deleteParentTransaction(
    int id, {
    bool keepChildTransactions = false,
  });
}
