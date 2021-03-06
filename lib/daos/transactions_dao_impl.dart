part of '../models/entities/database.dart';

@UseDao(tables: [Transactions, Categories])
class TransactionsDaoImpl extends DatabaseAccessor<AppDatabase>
    with _$TransactionsDaoImplMixin
    implements TransactionsDao {
  TransactionsDaoImpl(AppDatabase db) : super(db);

  @override
  Future<List<TransactionItem>> getAllTransactions(
    int userId,
    DateTime from,
    DateTime to,
  ) {
    final query = (select(transactions)
          ..where(
            (t) =>
                t.localStatus.equals(LocalStatusType.deleted.index).not() &
                t.transactionDate.isBetweenValues(from, to) &
                t.isParentTransaction.not(),
          ))
        .join([
      innerJoin(categories, categories.id.equalsExp(transactions.categoryId)),
    ]);
    if (userId == null) {
      return (query..where((isNull(categories.userId)))).map(_mapToTransactionItem).get();
    }
    return (query..where(categories.userId.equals(userId))).map(_mapToTransactionItem).get();
  }

  @override
  Future<TransactionItem> saveTransaction(TransactionItem transaction) async {
    Transaction savedTransaction;

    final now = DateTime.now();
    if (transaction.id <= 0) {
      final id = await into(transactions).insert(Transaction(
        localStatus: LocalStatusType.created,
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
        longDescription: transaction.longDescription,
      ));

      final query = select(transactions)..where((t) => t.id.equals(id));
      savedTransaction = (await query.get()).first;
    } else {
      final currentTrans = await (select(transactions)..where((t) => t.id.equals(transaction.id))).getSingle();

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
        localStatus: currentTrans.localStatus == LocalStatusType.created
            ? const Value(LocalStatusType.created)
            : const Value(LocalStatusType.updated),
        longDescription: Value(transaction.longDescription),
      );
      await (update(transactions)..where((t) => t.id.equals(transaction.id))).write(updatedFields);

      final isNoLongerAParent = currentTrans.isParentTransaction && !transaction.isParentTransaction;

      if (isNoLongerAParent) {
        final childTransactions = await _getChildTransactions(transaction.id);
        await batch((b) {
          for (final child in childTransactions) {
            final updatedFields = TransactionsCompanion(
              repetitionCycle: const Value(RepetitionCycleType.none),
              parentTransactionId: const Value(null),
              updatedAt: Value(now),
              updatedBy: const Value(createdBy),
              localStatus: child.localStatus == LocalStatusType.created
                  ? const Value(LocalStatusType.created)
                  : const Value(LocalStatusType.updated),
            );
            b.update<Transactions, Transaction>(
              transactions,
              updatedFields,
              where: (t) => t.id.equals(child.id),
            );
          }
        });
      }

      final query = select(transactions)..where((t) => t.id.equals(transaction.id));
      savedTransaction = (await query.get()).first;
    }

    return TransactionItem(
      amount: savedTransaction.amount,
      category: transaction.category,
      description: savedTransaction.description,
      id: savedTransaction.id,
      repetitionCycle: savedTransaction.repetitionCycle,
      transactionDate: savedTransaction.transactionDate,
      imagePath: savedTransaction.imagePath,
      isParentTransaction: savedTransaction.isParentTransaction,
      nextRecurringDate: savedTransaction.nextRecurringDate,
      parentTransactionId: savedTransaction.parentTransactionId,
    );
  }

  @override
  Future<bool> deleteTransaction(int id) async {
    final trans = await (select(transactions)..where((t) => t.id.equals(id))).getSingle();

    if (trans.localStatus == LocalStatusType.created) {
      await (delete(transactions)..where((t) => t.id.equals(id))).go();
    }

    await (update(transactions)..where((t) => t.id.equals(id))).write(
      TransactionsCompanion(
        updatedAt: Value(DateTime.now()),
        updatedBy: const Value(createdBy),
        localStatus: const Value(LocalStatusType.deleted),
      ),
    );
    return true;
  }

  @override
  Future<List<TransactionItem>> getAllParentTransactions(
    int userId,
  ) {
    final query = (select(transactions)
          ..where(
            (t) =>
                t.localStatus.equals(LocalStatusType.deleted.index).not() &
                t.repetitionCycle.equals(RepetitionCycleType.none.index).not() &
                t.isParentTransaction,
          ))
        .join([
      innerJoin(
        categories,
        categories.id.equalsExp(transactions.categoryId),
      ),
    ]);

    if (userId == null) {
      return (query..where((isNull(categories.userId)))).map(_mapToTransactionItem).get();
    }

    return (query..where(categories.userId.equals(userId))).map(_mapToTransactionItem).get();
  }

  @override
  Future<List<TransactionItem>> getAllParentTransactionsUntil(
    int userId,
    DateTime until,
  ) {
    final query = (select(transactions)
          ..where(
            (t) =>
                t.localStatus.equals(LocalStatusType.deleted.index).not() &
                t.repetitionCycle.equals(RepetitionCycleType.none.index).not() &
                isNotNull(t.nextRecurringDate) &
                t.nextRecurringDate.isSmallerOrEqualValue(until) &
                t.isParentTransaction,
          ))
        .join([
      innerJoin(
        categories,
        categories.id.equalsExp(transactions.categoryId),
      ),
    ]);

    if (userId == null) {
      return (query..where((isNull(categories.userId)))).map(_mapToTransactionItem).get();
    }

    return (query..where(categories.userId.equals(userId))).map(_mapToTransactionItem).get();
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
                t.localStatus.equals(LocalStatusType.deleted.index).not() &
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
  Future<List<TransactionItem>> checkAndSaveRecurringTransactions(
    TransactionItem parent,
    DateTime nextRecurringDate,
    List<DateTime> periods,
  ) async {
    final transToSave = _buildChildTransactions(
      parent,
      periods,
    );

    if (transToSave.isEmpty) {
      return [];
    }

    final currentParent = await (select(transactions)..where((c) => c.id.equals(parent.id))).getSingle();

    await batch((b) {
      final updatedFields = TransactionsCompanion(
        nextRecurringDate: Value(nextRecurringDate),
        updatedBy: const Value(createdBy),
        updatedAt: Value(DateTime.now()),
        localStatus: currentParent.localStatus == LocalStatusType.created
            ? const Value(LocalStatusType.created)
            : const Value(LocalStatusType.updated),
      );

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

    return (select(transactions)
          ..where(
            (t) =>
                isNotNull(t.parentTransactionId) &
                t.parentTransactionId.equals(parent.id) &
                t.transactionDate.isIn(periods),
          ))
        .join([
          innerJoin(
            categories,
            categories.id.equalsExp(transactions.categoryId),
          )
        ])
        .map(_mapToTransactionItem)
        .get();
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
    final parentTrans = await (select(transactions)..where((c) => c.id.equals(id))).getSingle();

    final childs = await _getChildTransactions(id);

    if (keepChildTransactions) {
      await _deleteParentTransaction(parentTrans, childs);
    } else {
      await _deleteParentAndChildTransactions(parentTrans, childs);
    }
    return true;
  }

  @override
  Future<void> updateNextRecurringDate(
    int id,
    DateTime nextRecurringDate,
  ) async {
    final parentTrans = await (select(transactions)..where((c) => c.id.equals(id))).getSingle();

    return (update(transactions)..where((t) => t.id.equals(id))).write(
      TransactionsCompanion(
        nextRecurringDate: Value(nextRecurringDate),
        updatedBy: const Value(createdBy),
        updatedAt: Value(DateTime.now()),
        localStatus: parentTrans.localStatus == LocalStatusType.created
            ? const Value(LocalStatusType.created)
            : const Value(LocalStatusType.updated),
      ),
    );
  }

  @override
  Future<void> deleteAll(int userId) async {
    final joinStatement =
        select(transactions).join([innerJoin(categories, categories.id.equalsExp(transactions.categoryId))]);

    if (userId == null) {
      joinStatement.where(isNull(categories.userId));
    } else {
      joinStatement.where(categories.userId.equals(userId));
    }

    final transToDelete = await joinStatement.map((row) {
      final trans = row.readTable(transactions);
      return trans.id;
    }).get();

    return (delete(transactions)..where((t) => t.id.isIn(transToDelete))).go();
  }

  @override
  Future<List<sync_trans.Transaction>> getAllTransactionsToSync(
    int userId,
  ) async {
    final parents = await (select(transactions)
          ..where(
            (t) => t.isParentTransaction & t.localStatus.equals(LocalStatusType.deleted.index).not(),
          ))
        .get();

    final joinStatement = (select(transactions)
          ..where(
            (t) => t.localStatus.equals(LocalStatusType.deleted.index).not(),
          )
          ..orderBy(
            [(t) => OrderingTerm(expression: t.id)],
          ))
        .join([innerJoin(categories, categories.id.equalsExp(transactions.categoryId))]);
    if (userId == null) {
      joinStatement.where(isNull(categories.userId));
    } else {
      joinStatement.where(categories.userId.equals(userId));
    }

    return joinStatement.map((row) => _mapToTransactionToSync(parents, row)).get();
  }

  @override
  Future<void> syncDownDelete(
    int userId,
    List<sync_trans.Transaction> existingTrans,
  ) async {
    final joinStatement = (select(transactions)
          ..where(
            (t) => t.localStatus.equals(LocalStatusType.created.index).not(),
          ))
        .join([innerJoin(categories, categories.id.equalsExp(transactions.categoryId))]);
    if (userId == null) {
      joinStatement.where(isNull(categories.userId));
    } else {
      joinStatement.where(categories.userId.equals(userId));
    }

    final transInDb = await joinStatement.map((row) {
      final trans = row.readTable(transactions);
      return trans;
    }).get();

    final downloadedTransHash = existingTrans.map((t) => t.createdHash).toList();
    final transToDelete = transInDb.where((t) => !downloadedTransHash.contains(t.createdHash)).toList();

    final normalTrans =
        transToDelete.where((t) => !t.isParentTransaction && t.parentTransactionId == null).map((t) => t.id).toList();

    final parentTrans = transToDelete.where((t) => t.isParentTransaction).map((t) => t.id).toList();

    final childTrans = transToDelete.where((t) => t.parentTransactionId != null).map((t) => t.id).toList();

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
  Future<void> syncUpDelete(int userId) async {
    final childsQuery = (select(transactions)
          ..where(
            (t) => t.localStatus.equals(LocalStatusType.deleted.index) & isNotNull(t.parentTransactionId),
          ))
        .join([innerJoin(categories, categories.id.equalsExp(transactions.categoryId))]);

    final parentsQuery = (select(transactions)
          ..where(
            (t) => t.localStatus.equals(LocalStatusType.deleted.index) & isNull(t.parentTransactionId),
          ))
        .join([innerJoin(categories, categories.id.equalsExp(transactions.categoryId))]);

    if (userId == null) {
      childsQuery.where(isNull(categories.userId));
      parentsQuery.where(isNull(categories.userId));
    } else {
      childsQuery.where(categories.userId.equals(userId));
      parentsQuery.where(categories.userId.equals(userId));
    }

    final childIds = await childsQuery.map((row) {
      final trans = row.readTable(transactions);
      return trans.id;
    }).get();

    final parentsIds = await parentsQuery.map((row) {
      final trans = row.readTable(transactions);
      return trans.id;
    }).get();

    //first we delete the childs...
    await (delete(transactions)..where((t) => t.id.isIn(childIds))).go();

    //and then the parents
    await (delete(transactions)..where((t) => t.id.isIn(parentsIds))).go();
  }

  @override
  Future<void> syncDownCreate(
    int userId,
    List<sync_trans.Transaction> existingTrans,
  ) async {
    final joinStatement =
        select(transactions).join([innerJoin(categories, categories.id.equalsExp(transactions.categoryId))]);
    if (userId == null) {
      joinStatement.where(isNull(categories.userId));
    } else {
      joinStatement.where(categories.userId.equals(userId));
    }

    final localTransHash = await joinStatement.map((row) {
      final trans = row.readTable(transactions);
      return trans.createdHash;
    }).get();

    final transToBeCreated = existingTrans.where((t) => !localTransHash.contains(t.createdHash)).toList();

    final normalTrans = transToBeCreated.where(
      (t) => !t.isParentTransaction && t.parentTransactionCreatedHash == null,
    );

    final parentTrans = transToBeCreated.where((t) => t.isParentTransaction);

    final childTrans = transToBeCreated.where(
      (t) => t.parentTransactionCreatedHash != null,
    );

    final trans = await Stream.fromIterable(normalTrans).asyncMap((item) => _mapToTransaction(item)).toList();

    final parents = await Stream.fromIterable(parentTrans).asyncMap((item) => _mapToTransaction(item)).toList();

    await batch((b) {
      if (trans.isNotEmpty) {
        b.insertAll(transactions, trans);
      }

      if (parents.isNotEmpty) {
        b.insertAll(transactions, parents);
      }
    });

    //Childs must be inserted after inserting their parents
    final childs = await Stream.fromIterable(childTrans).asyncMap((item) => _mapToTransaction(item)).toList();

    await batch((b) {
      if (childs.isNotEmpty) {
        b.insertAll(transactions, childs);
      }
    });
  }

  @override
  Future<void> syncDownUpdate(
    int userId,
    List<sync_trans.Transaction> existingTrans,
  ) async {
    final existingTransToUse = existingTrans.where((t) => t.updatedAt != null).toList();
    final transHash = existingTransToUse.map((t) => t.createdHash).toList();
    final joinStatement = (select(transactions)
          ..where(
            (t) => t.createdHash.isIn(transHash),
          ))
        .join([innerJoin(categories, categories.id.equalsExp(transactions.categoryId))]);

    if (userId == null) {
      joinStatement.where(isNull(categories.userId));
    } else {
      joinStatement.where(categories.userId.equals(userId));
    }

    final transInDb = await joinStatement.map((row) => row.readTable(transactions)).get();

    final transToUpdate = <Transaction>[];
    final updatedCatsHash = <String>[];
    for (final updatedTrans in existingTransToUse) {
      final localTrans = transInDb.singleWhere((t) => t.createdHash == updatedTrans.createdHash);

      if (localTrans.updatedAt == null || localTrans.updatedAt.isBefore(updatedTrans.updatedAt)) {
        transToUpdate.add(localTrans);
        if (!updatedCatsHash.contains(updatedTrans.categoryCreatedHash)) {
          updatedCatsHash.add(updatedTrans.categoryCreatedHash);
        }
      }
    }

    if (transToUpdate.isEmpty) return;

    final cats = await (select(categories)..where((c) => c.createdHash.isIn(updatedCatsHash))).get();

    final parentsHash = existingTransToUse
        .where((t) => t.parentTransactionCreatedHash != null)
        .map((t) => t.parentTransactionCreatedHash)
        .toSet()
        .toList();

    final parents = await (select(transactions)..where((t) => t.createdHash.isIn(parentsHash))).get();

    await batch((b) {
      for (final trans in transToUpdate) {
        final updatedTrans = existingTransToUse.singleWhere((t) => t.createdHash == trans.createdHash);
        final parent = updatedTrans.parentTransactionCreatedHash != null
            ? parents.singleWhere(
                (t) => t.createdHash == updatedTrans.parentTransactionCreatedHash,
                orElse: () => null,
              )
            : null;

        final cat = cats.singleWhere(
          (c) => c.createdHash == updatedTrans.categoryCreatedHash,
        );

        b.update<Transactions, Transaction>(
          transactions,
          TransactionsCompanion(
            localStatus: const Value(LocalStatusType.nothing),
            amount: Value(updatedTrans.amount),
            categoryId: Value(cat.id),
            description: Value(updatedTrans.description),
            imagePath: Value(updatedTrans.imagePath),
            isParentTransaction: Value(updatedTrans.isParentTransaction),
            nextRecurringDate: Value(updatedTrans.nextRecurringDate),
            parentTransactionId: Value(parent?.id),
            repetitionCycle: Value(updatedTrans.repetitionCycle),
            transactionDate: Value(updatedTrans.transactionDate),
            updatedAt: Value(updatedTrans.updatedAt),
            updatedBy: Value(updatedTrans.updatedBy),
            longDescription: Value(updatedTrans.longDescription),
          ),
          where: (t) => t.id.equals(trans.id),
        );
      }
    });
  }

  @override
  Future<void> updateAllLocalStatus(LocalStatusType newValue) {
    return update(transactions).write(TransactionsCompanion(
      updatedAt: Value(DateTime.now()),
      updatedBy: const Value(createdBy),
      localStatus: Value(newValue),
    ));
  }

  @override
  Future<List<TransactionItem>> getAllTransactionsForSearch(
    int userId,
    DateTime from,
    DateTime to,
    String description,
    double amount,
    ComparerType comparerType,
    int categoryId,
    TransactionType transactionType,
    TransactionFilterType transactionFilterType,
    SortDirectionType sortDirectionType,
    int take,
    int skip,
  ) {
    var query = (select(transactions)
          ..where(
            (t) => t.localStatus.equals(LocalStatusType.deleted.index).not() & t.isParentTransaction.not(),
          ))
        .join([
      innerJoin(categories, categories.id.equalsExp(transactions.categoryId)),
    ]);
    if (userId == null) {
      query = query..where((isNull(categories.userId)));
    } else {
      query = query..where(categories.userId.equals(userId));
    }

    if (from != null) {
      query = query..where(transactions.transactionDate.isBiggerOrEqualValue(from));
    }

    if (to != null) {
      query = query..where(transactions.transactionDate.isSmallerOrEqualValue(to));
    }

    if (!description.isNullEmptyOrWhitespace) {
      query = query..where(transactions.description.contains(description));
    }

    if (amount != null) {
      switch (comparerType) {
        case ComparerType.equal:
          query = query..where(transactions.amount.abs().equals(amount));
          break;
        case ComparerType.greaterOrEqualThan:
          query = query..where(transactions.amount.abs().isBiggerOrEqualValue(amount));
          break;
        case ComparerType.lessOrEqualThan:
          query = query..where(transactions.amount.abs().isSmallerOrEqualValue(amount));
          break;
      }
    }

    if (categoryId != null) {
      query = query..where(transactions.categoryId.equals(categoryId));
    }

    if (transactionType != null) {
      query = query..where(categories.isAnIncome.equals(transactionType == TransactionType.incomes));
    }

    OrderingTerm orderingTerm;
    switch (transactionFilterType) {
      case TransactionFilterType.description:
        orderingTerm = sortDirectionType == SortDirectionType.asc
            ? OrderingTerm.asc(transactions.description)
            : OrderingTerm.desc(transactions.description);
        break;
      case TransactionFilterType.amount:
        orderingTerm = sortDirectionType == SortDirectionType.asc
            ? OrderingTerm.asc(transactions.amount.abs())
            : OrderingTerm.desc(transactions.amount.abs());
        break;
      case TransactionFilterType.date:
        orderingTerm = sortDirectionType == SortDirectionType.asc
            ? OrderingTerm.asc(transactions.transactionDate)
            : OrderingTerm.desc(transactions.transactionDate);
        break;
      case TransactionFilterType.category:
        orderingTerm = sortDirectionType == SortDirectionType.asc
            ? OrderingTerm.asc(categories.name)
            : OrderingTerm.desc(categories.name);
        break;
    }
    if (orderingTerm != null) {
      query = query..orderBy([orderingTerm]);
    }

    return (query..limit(take, offset: skip)).map(_mapToTransactionItem).get();
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
      localStatus: LocalStatusType.created,
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
      longDescription: parent.longDescription,
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
      longDescription: trans.longDescription,
    );
  }

  Future<List<Transaction>> _getChildTransactions(int parentId) {
    return (select(transactions)..where((t) => t.parentTransactionId.equals(parentId))).get();
  }

  Future<Transaction> _mapToTransaction(
    sync_trans.Transaction transaction,
  ) async {
    final cat = await (select(categories)
          ..where(
            (c) => c.createdHash.equals(transaction.categoryCreatedHash),
          ))
        .getSingle();

    int parentId;
    if (transaction.parentTransactionCreatedHash != null) {
      final parent = await (select(transactions)
            ..where((t) => t.createdHash.equals(transaction.parentTransactionCreatedHash)))
          .getSingle();
      parentId = parent.id;
    }
    return Transaction(
      localStatus: LocalStatusType.nothing,
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
      updatedAt: transaction.updatedAt,
      updatedBy: transaction.updatedBy,
      longDescription: transaction.longDescription,
    );
  }

  sync_trans.Transaction _mapToTransactionToSync(
    List<Transaction> parents,
    TypedResult row,
  ) {
    final cat = row.readTable(categories);
    final trans = row.readTable(transactions);
    final parentCreatedHash = trans.parentTransactionId != null
        ? parents.singleWhere((t) => t.id == trans.parentTransactionId).createdHash
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
      longDescription: trans.longDescription,
    );
  }

  Future<void> _deleteParentTransaction(
    Transaction parentTrans,
    List<Transaction> childs,
  ) {
    return batch((b) {
      for (final child in childs) {
        final updatedFields = TransactionsCompanion(
          repetitionCycle: const Value(RepetitionCycleType.none),
          parentTransactionId: const Value(null),
          updatedAt: Value(DateTime.now()),
          updatedBy: const Value(createdBy),
          localStatus: child.localStatus == LocalStatusType.created
              ? const Value(LocalStatusType.created)
              : const Value(LocalStatusType.updated),
        );
        b.update<Transactions, Transaction>(
          transactions,
          updatedFields,
          where: (t) => t.id.equals(child.id),
        );
      }

      if (parentTrans.localStatus == LocalStatusType.created) {
        b.deleteWhere<Transactions, Transaction>(
          transactions,
          (t) => t.id.equals(parentTrans.id),
        );
      } else {
        b.update<Transactions, Transaction>(
          transactions,
          TransactionsCompanion(
            updatedAt: Value(DateTime.now()),
            updatedBy: const Value(createdBy),
            localStatus: const Value(LocalStatusType.deleted),
          ),
          where: (t) => t.id.equals(parentTrans.id),
        );
      }
    });
  }

  Future<void> _deleteParentAndChildTransactions(
    Transaction parentTrans,
    List<Transaction> childs,
  ) {
    return batch((b) {
      for (final child in childs) {
        if (child.localStatus == LocalStatusType.created) {
          b.deleteWhere<Transactions, Transaction>(
            transactions,
            (t) => t.id.equals(child.id),
          );
        } else {
          b.update<Transactions, Transaction>(
            transactions,
            TransactionsCompanion(
              updatedAt: Value(DateTime.now()),
              updatedBy: const Value(createdBy),
              localStatus: const Value(LocalStatusType.deleted),
            ),
            where: (t) => t.id.equals(child.id),
          );
        }
      }

      if (parentTrans.localStatus == LocalStatusType.created) {
        b.deleteWhere<Transactions, Transaction>(
          transactions,
          (t) => t.id.equals(parentTrans.id),
        );
      } else {
        b.update<Transactions, Transaction>(
          transactions,
          TransactionsCompanion(
            updatedAt: Value(DateTime.now()),
            updatedBy: const Value(createdBy),
            localStatus: const Value(LocalStatusType.deleted),
          ),
          where: (t) => t.id.equals(parentTrans.id),
        );
      }
    });
  }
}
