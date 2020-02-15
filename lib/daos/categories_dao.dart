part of '../models/entities/database.dart';

@UseDao(tables: [Categories])
class CategoriesDao extends DatabaseAccessor<AppDatabase>
    with _$CategoriesDaoMixin {
  CategoriesDao(AppDatabase db) : super(db);

  Future<List<CategoryItem>> getAll() {
    var query = select(categories).map((row) => CategoryItem(
          row.id,
          row.isAnIncome,
          row.name,
          row.icon,
          row.iconColor,
        ));

    return query.get();
  }

  Future<List<CategoryItem>> getAllCategories(bool onlyIncomes) {
    if (onlyIncomes) return getAllIncomes();
    return getAllExpenses();
  }

  Future<List<CategoryItem>> getAllIncomes() {
    var query = select(categories)..where((c) => c.isAnIncome.equals(true));
    return query
        .map((row) => CategoryItem(
              row.id,
              row.isAnIncome,
              row.name,
              row.icon,
              row.iconColor,
            ))
        .get();
  }

  Future<List<CategoryItem>> getAllExpenses() {
    var query = select(categories)..where((c) => c.isAnIncome.equals(false));
    return query
        .map((row) => CategoryItem(
              row.id,
              row.isAnIncome,
              row.name,
              row.icon,
              row.iconColor,
            ))
        .get();
  }
}
