import '../common/enums/local_status_type.dart';
import '../models/drive/transaction.dart' as sync_trans;
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

  Future<void> updateNextRecurringDate(int id, DateTime nextRecurringDate);

  Future<void> deleteAll();

  Future<List<sync_trans.Transaction>> getAllTransactionsToSync();

  Future<void> deleteTransactions(List<sync_trans.Transaction> existingTrans);

  Future<void> createTransactions(List<sync_trans.Transaction> existingTrans);

  Future<void> updateTransactions(List<sync_trans.Transaction> existingTrans);

  Future<void> updateAllLocalStatus(LocalStatusType newValue);
}
