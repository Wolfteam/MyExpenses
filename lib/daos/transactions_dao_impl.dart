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

    final now = DateTime.now();
    if (transaction.id <= 0) {
      final id = await into(transactions).insert(Transaction(
        amount: transaction.amount,
        categoryId: transaction.category.id,
        createdBy: createdBy,
        createdAt: now,
        description: transaction.description,
        repetitionCycle: transaction.repetitionCycle,
        transactionDate: transaction.transactionDate,
        parentTransactionId: transaction.parentTransactionId,
        isParentTransaction: transaction.isParentTransaction,
        imagePath: transaction.imagePath,
        nextRecurringDate: transaction.nextRecurringDate,
        createdHash: createdHash([
          transaction.amount,
          transaction.category.id,
          createdBy,
          now,
          transaction.description,
          transaction.repetitionCycle,
          transaction.transactionDate,
          transaction.parentTransactionId,
          transaction.isParentTransaction,
          transaction.imagePath,
          transaction.nextRecurringDate,
        ]),
      ));

      final query = select(transactions)..where((t) => t.id.equals(id));
      savedTransaction = (await query.get()).first;
    } else {
      final currentTrans = await (select(transactions)
            ..where((t) => t.id.equals(transaction.id)))
          .getSingle();

      final updatedFields = TransactionsCompanion(
        amount: Value(transaction.amount),
        description: Value(transaction.description),
        repetitionCycle: Value(transaction.repetitionCycle),
        categoryId: Value(transaction.category.id),
        transactionDate: Value(transaction.transactionDate),
        updatedAt: Value(now),
        updatedBy: const Value(createdBy),
        parentTransactionId: Value(transaction.parentTransactionId),
        isParentTransaction: Value(transaction.isParentTransaction),
        imagePath: Value(transaction.imagePath),
        nextRecurringDate: Value(transaction.nextRecurringDate),
      );
      await (update(transactions)..where((t) => t.id.equals(transaction.id)))
          .write(updatedFields);

      final isNoLongerAParent =
          currentTrans.isParentTransaction && !transaction.isParentTransaction;

      if (isNoLongerAParent) {
        final childTransactions = await _getChildTransactions(transaction.id);
        final updatedFields = TransactionsCompanion(
          repetitionCycle: const Value(RepetitionCycleType.none),
          parentTransactionId: const Value(null),
          updatedAt: Value(now),
          updatedBy: const Value(createdBy),
        );
        await batch((b) {
          for (final child in childTransactions) {
            b.update<Transactions, Transaction>(
              transactions,
              updatedFields,
              where: (t) => t.id.equals(child.id),
            );
          }
        });
      }

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
          ..where(
            (t) =>
                t.repetitionCycle.equals(RepetitionCycleType.none.index).not() &
                t.isParentTransaction,
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
  Future<List<TransactionItem>> getAllParentTransactionsUntil(DateTime until) {
    final query = (select(transactions)
          ..where(
            (t) =>
                t.repetitionCycle.equals(RepetitionCycleType.none.index).not() &
                t.nextRecurringDate.isSmallerOrEqualValue(until) &
                t.isParentTransaction,
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

  @override
  Future<TransactionItem> getTransaction(int id) async {
    final query = (select(transactions)..where((t) => t.id.equals(id))).join([
      innerJoin(categories, categories.id.equalsExp(transactions.categoryId)),
    ]).map(_mapToTransactionItem);

    return query.getSingle();
  }

  @override
  Future<bool> deleteParentTransaction(
    int id, {
    bool keepChildTransactions = false,
  }) async {
    if (keepChildTransactions) {
      final childTransactions = await _getChildTransactions(id);

      final updatedFields = TransactionsCompanion(
        repetitionCycle: const Value(RepetitionCycleType.none),
        parentTransactionId: const Value(null),
        updatedAt: Value(DateTime.now()),
        updatedBy: const Value(createdBy),
      );

      await batch((b) {
        for (final child in childTransactions) {
          b.update<Transactions, Transaction>(
            transactions,
            updatedFields,
            where: (t) => t.id.equals(child.id),
          );
        }

        b.deleteWhere<Transactions, Transaction>(
          transactions,
          (t) => t.id.equals(id),
        );
      });
    } else {
      await batch((b) {
        b.deleteWhere<Transactions, Transaction>(
          transactions,
          (t) => t.parentTransactionId.equals(id),
        );

        b.deleteWhere<Transactions, Transaction>(
          transactions,
          (t) => t.id.equals(id),
        );
      });
    }
    return true;
  }

  @override
  Future<List<sync_trans.Transaction>> getAllTransactionsToSync() async {
    final parents =
        await (select(transactions)..where((t) => t.isParentTransaction)).get();

    return select(transactions).join([
      innerJoin(categories, categories.id.equalsExp(transactions.categoryId))
    ]).map((row) {
      final cat = row.readTable(categories);
      final trans = row.readTable(transactions);
      final parentCreatedHash = trans.parentTransactionId != null
          ? parents
              .singleWhere((t) => t.id == trans.parentTransactionId)
              .createdHash
          : null;
      return sync_trans.Transaction(
        amount: trans.amount,
        categoryCreatedHash: cat.createdHash,
        createdAt: trans.createdAt,
        createdBy: trans.createdBy,
        createdHash: trans.createdHash,
        description: trans.description,
        imagePath: trans.imagePath,
        isParentTransaction: trans.isParentTransaction,
        nextRecurringDate: trans.nextRecurringDate,
        parentTransactionCreatedHash: parentCreatedHash,
        repetitionCycle: trans.repetitionCycle,
        transactionDate: trans.transactionDate,
        updatedAt: trans.updatedAt,
        updatedBy: trans.updatedBy,
      );
    }).get();
  }

  @override
  Future<void> deleteTransactions(
    List<sync_trans.Transaction> existingTrans,
  ) async {
    final transInDb = await select(transactions).get();
    final downloadedTransHash =
        existingTrans.map((t) => t.createdHash).toList();
    final transToDelete = transInDb
        .where((t) => !downloadedTransHash.contains(t.createdHash))
        .toList();

    final normalTrans = transToDelete
        .where((t) => !t.isParentTransaction && t.parentTransactionId == null)
        .map((t) => t.id)
        .toList();

    final parentTrans = transToDelete
        .where((t) => t.isParentTransaction)
        .map((t) => t.id)
        .toList();

    final childTrans = transToDelete
        .where((t) => t.parentTransactionId != null)
        .map((t) => t.id)
        .toList();

    await batch((b) {
      if (childTrans.isNotEmpty) {
        b.deleteWhere<Transactions, Transaction>(
          transactions,
          (t) => t.id.isIn(childTrans),
        );
      }

      if (parentTrans.isNotEmpty) {
        b.deleteWhere<Transactions, Transaction>(
          transactions,
          (t) => t.id.isIn(parentTrans),
        );
      }

      if (normalTrans.isNotEmpty) {
        b.deleteWhere<Transactions, Transaction>(
          transactions,
          (t) => t.id.isIn(normalTrans),
        );
      }
    });
  }

  @override
  Future<void> createTransactions(
    List<sync_trans.Transaction> existingTrans,
  ) async {
    final transInDb = await (select(transactions)).get();
    final localTransHash = transInDb.map((t) => t.createdHash).toList();
    final transToBeCreated = existingTrans
        .where((t) => !localTransHash.contains(t.createdHash))
        .toList();

    final normalTrans = transToBeCreated.where(
      (t) => !t.isParentTransaction && t.parentTransactionCreatedHash == null,
    );

    final parentTrans = transToBeCreated.where((t) => !t.isParentTransaction);

    final childTrans = transToBeCreated.where(
      (t) => t.parentTransactionCreatedHash != null,
    );

    final trans = await Stream.fromIterable(normalTrans)
        .asyncMap((item) => _mapToTransaction(item))
        .toList();

    final parents = await Stream.fromIterable(parentTrans)
        .asyncMap((item) => _mapToTransaction(item))
        .toList();

    await batch((b) {
      if (trans.isNotEmpty) {
        b.insertAll(transactions, trans);
      }

      if (parents.isNotEmpty) {
        b.insertAll(transactions, parents);
      }
    });

    //Childs must be inserted after inserting their parents
    final childs = await Stream.fromIterable(childTrans)
        .asyncMap((item) => _mapToTransaction(item))
        .toList();

    await batch((b) {
      if (childs.isNotEmpty) {
        b.insertAll(transactions, childs);
      }
    });
  }

  @override
  Future<void> updateTransactions(
    List<sync_trans.Transaction> existingTrans,
  ) async {
    final existingTransToUse =
        existingTrans.where((t) => t.updatedAt != null).toList();
    final transHash = existingTransToUse.map((t) => t.createdHash).toList();
    final transInDb = await (select(transactions)
          ..where((t) => t.createdHash.isIn(transHash)))
        .get();

    final transToUpdate = <Transaction>[];
    for (final trans in existingTransToUse) {
      final localTrans =
          transInDb.singleWhere((t) => t.createdHash == trans.createdHash);

      if (localTrans.updatedAt == null ||
          localTrans.updatedAt.isBefore(trans.updatedAt)) {
        transToUpdate.add(localTrans);
      }
    }

    if (transToUpdate.isEmpty) return;

    final catsId = transToUpdate.map((t) => t.categoryId).toSet().toList();

    final cats =
        await (select(categories)..where((c) => c.id.isIn(catsId))).get();

    final parentsId = transToUpdate
        .where((t) => t.parentTransactionId != null)
        .map((t) => t.parentTransactionId)
        .toSet()
        .toList();

    final parents =
        await (select(transactions)..where((t) => t.id.isIn(parentsId))).get();

    await batch((b) {
      for (final trans in transToUpdate) {
        final updatedTrans = existingTransToUse
            .singleWhere((t) => t.createdHash == trans.createdHash);
        final parent = trans.parentTransactionId != null
            ? parents
                .singleWhere((t) => t.createdHash == updatedTrans.createdHash)
            : null;

        final cat = cats.singleWhere(
            (c) => c.createdHash == updatedTrans.categoryCreatedHash);

        b.update<Transactions, Transaction>(
          transactions,
          TransactionsCompanion(
            amount: Value(updatedTrans.amount),
            categoryId: Value(cat.id),
            description: Value(updatedTrans.description),
            imagePath: Value(updatedTrans.imagePath),
            isParentTransaction: Value(updatedTrans.isParentTransaction),
            nextRecurringDate: Value(updatedTrans.nextRecurringDate),
            parentTransactionId: Value(parent.id),
            repetitionCycle: Value(updatedTrans.repetitionCycle),
            transactionDate: Value(updatedTrans.transactionDate),
            updatedAt: Value(updatedTrans.updatedAt),
            updatedBy: Value(updatedTrans.updatedBy),
          ),
          where: (t) => t.id.equals(trans.id),
        );
      }
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
    final now = DateTime.now();
    return Transaction(
      amount: parent.amount,
      categoryId: parent.category.id,
      createdBy: createdBy,
      createdAt: now,
      repetitionCycle: parent.repetitionCycle,
      description: parent.description,
      parentTransactionId: parent.id,
      transactionDate: transactionDate,
      isParentTransaction: false,
      createdHash: createdHash([
        parent.amount,
        parent.category.id,
        createdBy,
        now,
        parent.description,
        parent.repetitionCycle,
        parent.id,
        transactionDate,
        false,
      ]),
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

  Future<List<Transaction>> _getChildTransactions(int parentId) {
    return (select(transactions)
          ..where((t) => t.parentTransactionId.equals(parentId)))
        .get();
  }

  Future<Transaction> _mapToTransaction(
    sync_trans.Transaction transaction,
  ) async {
    final cat = await (select(categories)
          ..where(
            (c) => c._createdHash.equals(transaction.categoryCreatedHash),
          ))
        .getSingle();

    int parentId;
    if (transaction.parentTransactionCreatedHash != null) {
      final parent = await (select(transactions)
            ..where((t) => t._createdHash
                .equals(transaction.parentTransactionCreatedHash)))
          .getSingle();
      parentId = parent.id;
    }
    return Transaction(
      amount: transaction.amount,
      categoryId: cat.id,
      createdBy: transaction.createdBy,
      createdAt: transaction.createdAt,
      description: transaction.description,
      repetitionCycle: transaction.repetitionCycle,
      transactionDate: transaction.transactionDate,
      parentTransactionId: parentId,
      isParentTransaction: transaction.isParentTransaction,
      imagePath: transaction.imagePath,
      nextRecurringDate: transaction.nextRecurringDate,
      createdHash: transaction.createdHash,
    );
  }
}
