import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/extensions/string_extensions.dart';
import 'package:my_expenses/domain/models/drive.dart' as drive;
import 'package:my_expenses/domain/models/entities.dart';
import 'package:my_expenses/domain/models/entities/daos/transactions_dao.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/domain/utils/date_utils.dart';
import 'package:my_expenses/domain/utils/transaction_utils.dart';
import 'package:my_expenses/infrastructure/db/database.dart';

part 'transactions_dao_impl.g.dart';

@DriftAccessor(tables: [Transactions, Categories])
class TransactionsDaoImpl extends DatabaseAccessor<AppDatabase> with _$TransactionsDaoImplMixin implements TransactionsDao {
  TransactionsDaoImpl(super.db);

  @override
  Future<List<TransactionItem>> getAllTransactions(int? userId, DateTime from, DateTime to) async {
    final query = (select(transactions)
          ..where(
            (t) =>
                t.localStatus.equals(LocalStatusType.deleted.index).not() & t.transactionDate.isBetweenValues(from, to) & t.isParentTransaction.not(),
          ))
        .join([
      innerJoin(categories, categories.id.equalsExp(transactions.categoryId)),
    ]);
    var results = <TypedResult>[];
    if (userId == null) {
      results = await (query..where(categories.userId.isNull())).get();
    } else {
      results = await (query..where(categories.userId.equals(userId))).get();
    }

    return results.map(_mapToTransactionItem).toList();
  }

  @override
  Future<TransactionItem> saveTransaction(TransactionItem transaction) async {
    Transaction savedTransaction;

    final now = DateTime.now();
    if (transaction.id <= 0) {
      final id = await into(transactions).insert(
        TransactionsCompanion.insert(
          localStatus: LocalStatusType.created,
          amount: transaction.amount,
          categoryId: transaction.category.id,
          createdBy: createdBy,
          createdAt: now,
          description: transaction.description,
          repetitionCycle: transaction.repetitionCycle,
          transactionDate: transaction.transactionDate,
          parentTransactionId: Value(transaction.parentTransactionId),
          isParentTransaction: transaction.isParentTransaction,
          imagePath: Value(transaction.imagePath),
          nextRecurringDate: Value(transaction.nextRecurringDate),
          createdHash: createdHash([
            transaction.amount,
            transaction.category.id,
            createdBy,
            now,
            transaction.description,
            transaction.repetitionCycle,
            transaction.transactionDate,
            transaction.parentTransactionId ?? -1,
            transaction.isParentTransaction,
          ]),
          longDescription: Value(transaction.longDescription),
        ),
      );

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
        localStatus:
            currentTrans.localStatus == LocalStatusType.created ? const Value(LocalStatusType.created) : const Value(LocalStatusType.updated),
        longDescription: Value(transaction.longDescription),
      );
      await (update(transactions)..where((t) => t.id.equals(transaction.id))).write(updatedFields);

      final isNoLongerAParent = currentTrans.isParentTransaction && !transaction.isParentTransaction;

      if (isNoLongerAParent) {
        final childTransactions = await _getChildrenTransactions(transaction.id);
        await batch((b) {
          for (final child in childTransactions) {
            final updatedFields = TransactionsCompanion(
              repetitionCycle: const Value(RepetitionCycleType.none),
              parentTransactionId: const Value(null),
              updatedAt: Value(now),
              updatedBy: const Value(createdBy),
              localStatus: child.localStatus == LocalStatusType.created ? const Value(LocalStatusType.created) : const Value(LocalStatusType.updated),
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
  Future<List<TransactionItem>> getAllParentTransactions(int? userId) async {
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

    var results = <TypedResult>[];
    if (userId == null) {
      results = await (query..where(categories.userId.isNull())).get();
    } else {
      results = await (query..where(categories.userId.equals(userId))).get();
    }

    return results.map(_mapToTransactionItem).toList();
  }

  @override
  Future<List<TransactionItem>> getAllParentTransactionsUntil(int? userId, DateTime until) async {
    final query = (select(transactions)
          ..where(
            (t) =>
                t.localStatus.equals(LocalStatusType.deleted.index).not() &
                t.repetitionCycle.equals(RepetitionCycleType.none.index).not() &
                t.nextRecurringDate.isNotNull() &
                t.nextRecurringDate.isSmallerOrEqualValue(until) &
                t.isParentTransaction,
          ))
        .join([
      innerJoin(
        categories,
        categories.id.equalsExp(transactions.categoryId),
      ),
    ]);

    var results = <TypedResult>[];
    if (userId == null) {
      results = await (query..where(categories.userId.isNull())).get();
    } else {
      results = await (query..where(categories.userId.equals(userId))).get();
    }

    return results.map(_mapToTransactionItem).toList();
  }

  @override
  Future<List<TransactionItem>> getAllChildTransactions(
    int parentId,
    DateTime from,
    DateTime to,
  ) async {
    final results = await (select(transactions)
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
    ]).get();

    return results.map(_mapToTransactionItem).toList();
  }

  @override
  Future<List<TransactionItem>> checkAndSaveRecurringTransactions(
    TransactionItem parent,
    DateTime nextRecurringDate,
    List<DateTime> periods,
  ) async {
    final transToSave = _buildChildTransactions(parent, periods);

    if (transToSave.isEmpty) {
      return [];
    }

    final currentParent = await (select(transactions)..where((c) => c.id.equals(parent.id))).getSingle();

    await batch((b) {
      final updatedFields = TransactionsCompanion(
        nextRecurringDate: Value(nextRecurringDate),
        updatedBy: const Value(createdBy),
        updatedAt: Value(DateTime.now()),
        localStatus:
            currentParent.localStatus == LocalStatusType.created ? const Value(LocalStatusType.created) : const Value(LocalStatusType.updated),
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

    final results = await (select(transactions)
          ..where(
            (t) => t.parentTransactionId.isNotNull() & t.parentTransactionId.equals(parent.id) & t.transactionDate.isIn(periods),
          ))
        .join([
      innerJoin(
        categories,
        categories.id.equalsExp(transactions.categoryId),
      ),
    ]).get();

    return results.map(_mapToTransactionItem).toList();
  }

  @override
  Future<TransactionItem> getTransaction(int id) async {
    final query = (select(transactions)..where((t) => t.id.equals(id))).join([
      innerJoin(categories, categories.id.equalsExp(transactions.categoryId)),
    ]).map(_mapToTransactionItem);

    return query.getSingle();
  }

  @override
  Future<bool> deleteParentTransaction(int id, {bool keepChildTransactions = false}) async {
    final parentTrans = await (select(transactions)..where((c) => c.id.equals(id))).getSingle();

    final children = await _getChildrenTransactions(id);

    if (keepChildTransactions) {
      await _deleteParentTransaction(parentTrans, children);
    } else {
      await _deleteParentAndChildTransactions(parentTrans, children);
    }
    return true;
  }

  @override
  Future<void> updateNextRecurringDate(int id, DateTime? nextRecurringDate) async {
    final parentTrans = await (select(transactions)..where((c) => c.id.equals(id))).getSingle();

    await (update(transactions)..where((t) => t.id.equals(id))).write(
      TransactionsCompanion(
        nextRecurringDate: Value(nextRecurringDate),
        updatedBy: const Value(createdBy),
        updatedAt: Value(DateTime.now()),
        localStatus: parentTrans.localStatus == LocalStatusType.created ? const Value(LocalStatusType.created) : const Value(LocalStatusType.updated),
      ),
    );
  }

  @override
  Future<void> deleteAll(int? userId) async {
    final joinStatement = select(transactions).join([innerJoin(categories, categories.id.equalsExp(transactions.categoryId))]);

    if (userId == null) {
      joinStatement.where(categories.userId.isNull());
    } else {
      joinStatement.where(categories.userId.equals(userId));
    }

    final transToDelete = await joinStatement.map((row) {
      final trans = row.readTable(transactions);
      return trans.id;
    }).get();

    await (delete(transactions)..where((t) => t.id.isIn(transToDelete))).go();
  }

  @override
  Future<List<drive.Transaction>> getAllTransactionsToSync(int? userId) async {
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
      joinStatement.where(categories.userId.isNull());
    } else {
      joinStatement.where(categories.userId.equals(userId));
    }

    return joinStatement.map((row) => _mapToTransactionToSync(parents, row)).get();
  }

  @override
  Future<void> syncDownDelete(int? userId, List<drive.Transaction> existingTrans) async {
    final joinStatement = (select(transactions)
          ..where(
            (t) => t.localStatus.equals(LocalStatusType.created.index).not(),
          ))
        .join([innerJoin(categories, categories.id.equalsExp(transactions.categoryId))]);
    if (userId == null) {
      joinStatement.where(categories.userId.isNull());
    } else {
      joinStatement.where(categories.userId.equals(userId));
    }

    final transInDb = await joinStatement.map((row) {
      final trans = row.readTable(transactions);
      return trans;
    }).get();

    final downloadedTransHash = existingTrans.map((t) => t.createdHash).toList();
    final transToDelete = transInDb.where((t) => !downloadedTransHash.contains(t.createdHash)).toList();

    final normalTrans = transToDelete.where((t) => !t.isParentTransaction && t.parentTransactionId == null).map((t) => t.id).toList();

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
  Future<void> syncUpDelete(int? userId) async {
    final childrenQuery = (select(transactions)
          ..where(
            (t) => t.localStatus.equals(LocalStatusType.deleted.index) & t.parentTransactionId.isNotNull(),
          ))
        .join([innerJoin(categories, categories.id.equalsExp(transactions.categoryId))]);

    final parentsQuery = (select(transactions)
          ..where(
            (t) => t.localStatus.equals(LocalStatusType.deleted.index) & t.parentTransactionId.isNull(),
          ))
        .join([innerJoin(categories, categories.id.equalsExp(transactions.categoryId))]);

    if (userId == null) {
      childrenQuery.where(categories.userId.isNull());
      parentsQuery.where(categories.userId.isNull());
    } else {
      childrenQuery.where(categories.userId.equals(userId));
      parentsQuery.where(categories.userId.equals(userId));
    }

    final childIds = await childrenQuery.map((row) {
      final trans = row.readTable(transactions);
      return trans.id;
    }).get();

    final parentsIds = await parentsQuery.map((row) {
      final trans = row.readTable(transactions);
      return trans.id;
    }).get();

    //first we delete the children...
    await (delete(transactions)..where((t) => t.id.isIn(childIds))).go();

    //and then the parents
    await (delete(transactions)..where((t) => t.id.isIn(parentsIds))).go();
  }

  @override
  Future<void> syncDownCreate(int? userId, List<drive.Transaction> existingTrans) async {
    final joinStatement = select(transactions).join([innerJoin(categories, categories.id.equalsExp(transactions.categoryId))]);
    if (userId == null) {
      joinStatement.where(categories.userId.isNull());
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

    //Children must be inserted after inserting their parents
    final children = await Stream.fromIterable(childTrans).asyncMap((item) => _mapToTransaction(item)).toList();

    await batch((b) {
      if (children.isNotEmpty) {
        b.insertAll(transactions, children);
      }
    });
  }

  @override
  Future<void> syncDownUpdate(int? userId, List<drive.Transaction> existingTrans) async {
    final existingTransToUse = existingTrans.where((t) => t.updatedAt != null).toList();
    final transHash = existingTransToUse.map((t) => t.createdHash).toList();
    final joinStatement = (select(transactions)
          ..where(
            (t) => t.createdHash.isIn(transHash),
          ))
        .join([innerJoin(categories, categories.id.equalsExp(transactions.categoryId))]);

    if (userId == null) {
      joinStatement.where(categories.userId.isNull());
    } else {
      joinStatement.where(categories.userId.equals(userId));
    }

    final transInDb = await joinStatement.map((row) => row.readTable(transactions)).get();

    final transToUpdate = <Transaction>[];
    final updatedCatsHash = <String>[];
    for (final updatedTrans in existingTransToUse) {
      final localTrans = transInDb.singleWhere((t) => t.createdHash == updatedTrans.createdHash);

      if (localTrans.updatedAt == null || updatedTrans.updatedAt != null && localTrans.updatedAt!.isBefore(updatedTrans.updatedAt!)) {
        transToUpdate.add(localTrans);
        if (!updatedCatsHash.contains(updatedTrans.categoryCreatedHash)) {
          updatedCatsHash.add(updatedTrans.categoryCreatedHash);
        }
      }
    }

    if (transToUpdate.isEmpty) return;

    final cats = await (select(categories)..where((c) => c.createdHash.isIn(updatedCatsHash))).get();

    final parentsHash =
        existingTransToUse.where((t) => t.parentTransactionCreatedHash != null).map((t) => t.parentTransactionCreatedHash!).toSet().toList();

    final parents = await (select(transactions)..where((t) => t.createdHash.isIn(parentsHash))).get();

    await batch((b) {
      for (final trans in transToUpdate) {
        final updatedTrans = existingTransToUse.singleWhere((t) => t.createdHash == trans.createdHash);
        final parent = updatedTrans.parentTransactionCreatedHash != null
            ? parents.singleWhereOrNull((t) => t.createdHash == updatedTrans.parentTransactionCreatedHash)
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
    return update(transactions).write(
      TransactionsCompanion(
        updatedAt: Value(DateTime.now()),
        updatedBy: const Value(createdBy),
        localStatus: Value(newValue),
      ),
    );
  }

  @override
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
  ) async {
    var query = (select(transactions)
          ..where(
            (t) => t.localStatus.equals(LocalStatusType.deleted.index).not() & t.isParentTransaction.not(),
          ))
        .join([
      innerJoin(categories, categories.id.equalsExp(transactions.categoryId)),
    ]);
    if (userId == null) {
      query = query..where(categories.userId.isNull());
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
      query = query..where(transactions.description.contains(description!));
    }

    if (amount != null) {
      switch (comparerType) {
        case ComparerType.equal:
          query = query..where(transactions.amount.abs().equals(amount));
        case ComparerType.greaterOrEqualThan:
          query = query..where(transactions.amount.abs().isBiggerOrEqualValue(amount));
        case ComparerType.lessOrEqualThan:
          query = query..where(transactions.amount.abs().isSmallerOrEqualValue(amount));
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
        orderingTerm =
            sortDirectionType == SortDirectionType.asc ? OrderingTerm.asc(transactions.description) : OrderingTerm.desc(transactions.description);
      case TransactionFilterType.amount:
        orderingTerm =
            sortDirectionType == SortDirectionType.asc ? OrderingTerm.asc(transactions.amount.abs()) : OrderingTerm.desc(transactions.amount.abs());
      case TransactionFilterType.date:
        orderingTerm = sortDirectionType == SortDirectionType.asc
            ? OrderingTerm.asc(transactions.transactionDate)
            : OrderingTerm.desc(transactions.transactionDate);
      case TransactionFilterType.category:
        orderingTerm = sortDirectionType == SortDirectionType.asc ? OrderingTerm.asc(categories.name) : OrderingTerm.desc(categories.name);
    }
    query = query..orderBy([orderingTerm]);

    final results = await (query..limit(take, offset: skip)).get();
    return results.map(_mapToTransactionItem).toList();
  }

  @override
  Future<List<TransactionItem>> saveRecurringTransactions(DateTime now, int? userId) async {
    final createdChildren = <TransactionItem>[];
    final until = DateUtils.getLastDayDateOfTheMonth(now);
    final parents = await getAllParentTransactionsUntil(userId, until);

    if (parents.isEmpty) {
      return createdChildren;
    }

    for (final parent in parents) {
      if (parent.repetitionCycle == RepetitionCycleType.none) {
        continue;
      }

      final tuple = TransactionUtils.getRecurringTransactionPeriods(parent.repetitionCycle, parent.transactionDate, parent.nextRecurringDate!, now);
      final nextRecurringDate = tuple.$1;
      final periods = tuple.$2;
      final children = await checkAndSaveRecurringTransactions(parent, nextRecurringDate, periods);

      createdChildren.addAll(children);
    }

    return createdChildren;
  }

  List<TransactionsCompanion> _buildChildTransactions(TransactionItem parent, List<DateTime> periods) {
    return periods.map((p) => _buildFromParent(parent, p)).toList();
  }

  TransactionsCompanion _buildFromParent(TransactionItem parent, DateTime transactionDate) {
    final now = DateTime.now();
    return TransactionsCompanion.insert(
      localStatus: LocalStatusType.created,
      amount: parent.amount,
      categoryId: parent.category.id,
      createdBy: createdBy,
      createdAt: now,
      repetitionCycle: parent.repetitionCycle,
      description: parent.description,
      parentTransactionId: Value(parent.id),
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
      longDescription: Value(parent.longDescription),
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
        isSelected: true,
      ),
      longDescription: trans.longDescription,
    );
  }

  Future<List<Transaction>> _getChildrenTransactions(int parentId) {
    return (select(transactions)..where((t) => t.parentTransactionId.equals(parentId))).get();
  }

  Future<TransactionsCompanion> _mapToTransaction(drive.Transaction transaction) async {
    final cat = await (select(categories)
          ..where(
            (c) => c.createdHash.equals(transaction.categoryCreatedHash),
          ))
        .getSingle();

    int? parentId;
    if (transaction.parentTransactionCreatedHash != null) {
      final parent = await (select(transactions)..where((t) => t.createdHash.equals(transaction.parentTransactionCreatedHash!))).getSingle();
      parentId = parent.id;
    }
    return TransactionsCompanion.insert(
      localStatus: LocalStatusType.nothing,
      amount: transaction.amount,
      categoryId: cat.id,
      createdBy: transaction.createdBy,
      createdAt: transaction.createdAt,
      description: transaction.description,
      repetitionCycle: transaction.repetitionCycle,
      transactionDate: transaction.transactionDate,
      parentTransactionId: Value(parentId),
      isParentTransaction: transaction.isParentTransaction,
      imagePath: Value(transaction.imagePath),
      nextRecurringDate: Value(transaction.nextRecurringDate),
      createdHash: transaction.createdHash,
      updatedAt: Value(transaction.updatedAt),
      updatedBy: Value(transaction.updatedBy),
      longDescription: Value(transaction.longDescription),
    );
  }

  drive.Transaction _mapToTransactionToSync(List<Transaction> parents, TypedResult row) {
    final cat = row.readTable(categories);
    final trans = row.readTable(transactions);
    final parentCreatedHash = trans.parentTransactionId != null ? parents.singleWhere((t) => t.id == trans.parentTransactionId).createdHash : null;
    return drive.Transaction(
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

  Future<void> _deleteParentTransaction(Transaction parentTrans, List<Transaction> children) {
    return batch((b) {
      for (final child in children) {
        final updatedFields = TransactionsCompanion(
          repetitionCycle: const Value(RepetitionCycleType.none),
          parentTransactionId: const Value(null),
          updatedAt: Value(DateTime.now()),
          updatedBy: const Value(createdBy),
          localStatus: child.localStatus == LocalStatusType.created ? const Value(LocalStatusType.created) : const Value(LocalStatusType.updated),
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

  Future<void> _deleteParentAndChildTransactions(Transaction parentTrans, List<Transaction> children) {
    return batch((b) {
      for (final child in children) {
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
