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
          amount: trans.amount,
          description: trans.description,
          repetitions: trans.repetitions,
          transactionDate: trans.transactionDate,
          category: CategoryItem(
            cat.id,
            cat.isAnIncome,
            cat.name,
            cat.icon,
            Color(cat.iconColor),
          ),
        );
      },
    );

    return query.get();
  }
}
