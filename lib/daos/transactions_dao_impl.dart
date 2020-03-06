part of '../models/entities/database.dart';

@UseDao(tables: [Transactions, Categories])
class TransactionsDaoImpl extends DatabaseAccessor<AppDatabase>
    with _$TransactionsDaoImplMixin
    implements TransactionsDao {
  TransactionsDaoImpl(AppDatabase db) : super(db);

  @override
  Future<List<TransactionItem>> getAllTransactions(DateTime from, DateTime to) {
    final query = (select(transactions)
          ..where(
            (t) =>
                t.transactionDate.isBetweenValues(from, to) &
                t.isParentTransaction.not(),
          ))
        .join([
      innerJoin(categories, categories.id.equalsExp(transactions.categoryId)),
    ]).map(_mapToTransactionItem);

    return query.get();
  }

  @override
  Future<TransactionItem> saveTransaction(TransactionItem transaction) async {
    Transaction savedTransaction;

    if (transaction.id <= 0) {
      final id = await into(transactions).insert(Transaction(
        amount: transaction.amount,
        categoryId: transaction.category.id,
        createdBy: 'Someone',
        description: transaction.description,
        repetitionCycle: transaction.repetitionCycle,
        transactionDate: transaction.transactionDate,
        parentTransactionId: transaction.parentTransactionId,
        isParentTransaction: transaction.isParentTransaction,
        imagePath: transaction.imagePath,
        nextRecurringDate: transaction.nextRecurringDate,
      ));

      final query = select(transactions)..where((t) => t.id.equals(id));
      savedTransaction = (await query.get()).first;
    } else {
      final updatedFields = TransactionsCompanion(
        amount: Value(transaction.amount),
        description: Value(transaction.description),
        repetitionCycle: Value(transaction.repetitionCycle),
        categoryId: Value(transaction.category.id),
        transactionDate: Value(transaction.transactionDate),
        updatedAt: Value(DateTime.now()),
        updatedBy: Value('somebody'),
        parentTransactionId: Value(transaction.parentTransactionId),
        isParentTransaction: Value(transaction.isParentTransaction),
        imagePath: Value(transaction.imagePath),
        nextRecurringDate: Value(transaction.nextRecurringDate),
      );
      await (update(transactions)..where((t) => t.id.equals(transaction.id)))
          .write(updatedFields);

      final query = select(transactions)
        ..where((t) => t.id.equals(transaction.id));
      savedTransaction = (await query.get()).first;
    }

    return TransactionItem(
      amount: savedTransaction.amount,
      category: transaction.category,
      description: savedTransaction.description,
      id: savedTransaction.id,
      repetitionCycle: savedTransaction.repetitionCycle,
      transactionDate: savedTransaction.transactionDate,
    );
  }

  @override
  Future<bool> deleteTransaction(int id) async {
    await (delete(transactions)..where((t) => t.id.equals(id))).go();
    return true;
  }

  @override
  Future<List<TransactionItem>> getAllParentTransactions() {
    final query = (select(transactions)
          ..where((t) =>
              t.repetitionCycle.equals(RepetitionCycleType.none.index).not() &
              isNull(t.parentTransactionId)))
        .join([
      innerJoin(
        categories,
        categories.id.equalsExp(transactions.categoryId),
      ),
    ]).map(_mapToTransactionItem);

    return query.get();
  }

  @override
  Future<List<TransactionItem>> getAllParentTransactionsUntil(DateTime until) {
    final query = (select(transactions)
          ..where(
            (t) =>
                t.repetitionCycle.equals(RepetitionCycleType.none.index).not() &
                isNull(t.parentTransactionId) &
                t.nextRecurringDate.isSmallerOrEqualValue(until),
          ))
        .join([
      innerJoin(
        categories,
        categories.id.equalsExp(transactions.categoryId),
      ),
    ]).map(_mapToTransactionItem);

    return query.get();
  }

  @override
  Future<List<TransactionItem>> getAllChildTransactions(
    int parentId,
    DateTime from,
    DateTime to,
  ) async {
    final query = (select(transactions)
          ..where(
            (t) =>
                t.repetitionCycle.equals(RepetitionCycleType.none.index).not() &
                t.parentTransactionId.equals(parentId) &
                t.transactionDate.isBetweenValues(from, to),
          ))
        .join([
      innerJoin(
        categories,
        categories.id.equalsExp(transactions.categoryId),
      ),
    ]).map(_mapToTransactionItem);

    return query.get();
  }

  @override
  Future<bool> deleteAllChildTransactions(int parentId) async {
    await (delete(transactions)
          ..where((t) => t.parentTransactionId.equals(parentId)))
        .go();
    return true;
  }

  @override
  Future<void> checkAndSaveRecurringTransactions(
    TransactionItem parent,
    DateTime nextRecurringDate,
    List<DateTime> periods,
  ) async {
    final transToSave = _buildChildTransactions(
      parent,
      periods,
    );

    if (transToSave.isEmpty) {
      return;
    }

    await batch((b) {
      final updatedFields =
          TransactionsCompanion(nextRecurringDate: Value(nextRecurringDate));

      b.update<$TransactionsTable, Transaction>(
        transactions,
        updatedFields,
        where: (t) => t.id.equals(parent.id),
      );
      b.insertAll(
        transactions,
        transToSave,
        mode: InsertMode.insertOrRollback,
      );
    });
  }

  List<Transaction> _buildChildTransactions(
    TransactionItem parent,
    List<DateTime> periods,
  ) {
    return periods.map((p) => _buildFromParent(parent, p)).toList();
  }

  Transaction _buildFromParent(
    TransactionItem parent,
    DateTime transactionDate,
  ) {
    return Transaction(
      amount: parent.amount,
      categoryId: parent.category.id,
      createdBy: 'ebastidas',
      repetitionCycle: parent.repetitionCycle,
      description: parent.description,
      parentTransactionId: parent.id,
      transactionDate: transactionDate,
      isParentTransaction: false,
    );
  }

  TransactionItem _mapToTransactionItem(TypedResult row) {
    final cat = row.readTable(categories);
    final trans = row.readTable(transactions);
    return TransactionItem(
      id: trans.id,
      amount: trans.amount,
      description: trans.description,
      repetitionCycle: trans.repetitionCycle,
      transactionDate: trans.transactionDate,
      parentTransactionId: trans.parentTransactionId,
      isParentTransaction: trans.isParentTransaction,
      nextRecurringDate: trans.nextRecurringDate,
      imagePath: trans.imagePath,
      category: CategoryItem(
        id: cat.id,
        isAnIncome: cat.isAnIncome,
        name: cat.name,
        icon: cat.icon,
        iconColor: cat.iconColor,
        isSeleted: true,
      ),
    );
  }
}
