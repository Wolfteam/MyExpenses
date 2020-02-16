part of '../models/entities/database.dart';

@UseDao(tables: [Transactions, Categories])
class TransactionsDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionsDaoMixin {
  TransactionsDao(AppDatabase db) : super(db);

  Future<List<TransactionItem>> getAll(DateTime from, DateTime to) {
    final query = (select(transactions)
          ..where((t) => t.transactionDate.isBetweenValues(from, to)))
        .join([
      innerJoin(categories, categories.id.equalsExp(transactions.categoryId)),
    ]).map(
      (rows) {
        final cat = rows.readTable(categories);
        final trans = rows.readTable(transactions);
        return TransactionItem(
          id: trans.id,
          amount: trans.amount,
          description: trans.description,
          repetitions: trans.repetitions,
          repetitionCycleType: trans.repetitionCycle,
          transactionDate: trans.transactionDate,
          category: CategoryItem(
            id: cat.id,
            isAnIncome: cat.isAnIncome,
            name: cat.name,
            icon: cat.icon,
            iconColor: cat.iconColor,
            isSeleted: true,
          ),
        );
      },
    );

    return query.get();
  }

  Future<TransactionItem> save(TransactionItem transaction) async {
    Transaction savedTransaction;

    if (transaction.id <= 0) {
      final id = await into(transactions).insert(Transaction(
        amount: transaction.amount,
        categoryId: transaction.category.id,
        createdBy: 'Someone',
        description: transaction.description,
        repetitionCycle: transaction.repetitionCycleType,
        repetitions: transaction.repetitions,
        transactionDate: transaction.transactionDate,
      ));

      final query = select(transactions)..where((t) => t.id.equals(id));
      savedTransaction = (await query.get()).first;
    } else {
      final updatedFields = TransactionsCompanion(
        amount: Value(transaction.amount),
        description: Value(transaction.description),
        repetitionCycle: Value(transaction.repetitionCycleType),
        categoryId: Value(transaction.category.id),
        repetitions: Value(transaction.repetitions),
        transactionDate: Value(transaction.transactionDate),
        updatedAt: Value(DateTime.now()),
        updatedBy: Value('somebody'),
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
      repetitionCycleType: savedTransaction.repetitionCycle,
      repetitions: savedTransaction.repetitions,
      transactionDate: savedTransaction.transactionDate,
    );
  }
}
