import '../models/transaction_item.dart';

abstract class TransactionsDao {
  Future<List<TransactionItem>> getAllTransactions(DateTime from, DateTime to);

  Future<TransactionItem> saveTransaction(TransactionItem transaction);

  Future<bool> deleteTransaction(int id);
}
