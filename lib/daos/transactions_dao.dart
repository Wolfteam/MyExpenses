import '../common/enums/comparer_type.dart';
import '../common/enums/local_status_type.dart';
import '../common/enums/sort_direction_type.dart';
import '../common/enums/transaction_filter_type.dart';
import '../common/enums/transaction_type.dart';
import '../models/drive/transaction.dart' as sync_trans;
import '../models/transaction_item.dart';

abstract class TransactionsDao {
  Future<List<TransactionItem>> getAllTransactions(
    int? userId,
    DateTime from,
    DateTime to,
  );

  Future<TransactionItem> saveTransaction(TransactionItem transaction);

  Future<bool> deleteTransaction(int id);

  Future<List<TransactionItem>> getAllParentTransactions(
    int? userId,
  );

  Future<List<TransactionItem>> getAllParentTransactionsUntil(
    int? userId,
    DateTime until,
  );

  Future<List<TransactionItem>> getAllChildTransactions(
    int parentId,
    DateTime from,
    DateTime to,
  );

  Future<List<TransactionItem>> checkAndSaveRecurringTransactions(
    TransactionItem parent,
    DateTime nextRecurringDate,
    List<DateTime> periods,
  );

  Future<TransactionItem> getTransaction(int id);

  Future<bool> deleteParentTransaction(
    int id, {
    bool keepChildTransactions = false,
  });

  Future<void> updateNextRecurringDate(int id, DateTime? nextRecurringDate);

  Future<void> deleteAll(int? userId);

  Future<List<sync_trans.Transaction>> getAllTransactionsToSync(
    int? userId,
  );

  Future<void> syncDownDelete(
    int? userId,
    List<sync_trans.Transaction> existingTrans,
  );

  Future<void> syncUpDelete(int? userId);

  Future<void> syncDownCreate(
    int? userId,
    List<sync_trans.Transaction> existingTrans,
  );

  Future<void> syncDownUpdate(
    int? userId,
    List<sync_trans.Transaction> existingTrans,
  );

  Future<void> updateAllLocalStatus(LocalStatusType newValue);

  Future<List<TransactionItem>> getAllTransactionsForSearch(
    int? userId,
    DateTime? from,
    DateTime? to,
    String? description,
    double? amount,
    ComparerType comparerType,
    int? categoryId,
    TransactionType? transactionType,
    TransactionFilterType transactionFilterType,
    SortDirectionType sortDirectionType,
    int take,
    int skip,
  );
}
