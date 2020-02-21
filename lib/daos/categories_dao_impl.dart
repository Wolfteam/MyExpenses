part of '../models/entities/database.dart';

@UseDao(tables: [Categories])
class CategoriesDaoImpl extends DatabaseAccessor<AppDatabase>
    with _$CategoriesDaoImplMixin
    implements CategoriesDao {
  CategoriesDaoImpl(AppDatabase db) : super(db);

  @override
  Future<List<CategoryItem>> getAll() {
    var query = select(categories).map((row) => CategoryItem(
          id: row.id,
          isAnIncome: row.isAnIncome,
          name: row.name,
          icon: row.icon,
          iconColor: row.iconColor,
        ));

    return query.get();
  }

  @override
  Future<List<CategoryItem>> getAllCategories(bool onlyIncomes) {
    if (onlyIncomes) return getAllIncomes();
    return getAllExpenses();
  }

  @override
  Future<List<CategoryItem>> getAllIncomes() {
    var query = select(categories)..where((c) => c.isAnIncome.equals(true));
    return query
        .map((row) => CategoryItem(
              id: row.id,
              isAnIncome: row.isAnIncome,
              name: row.name,
              icon: row.icon,
              iconColor: row.iconColor,
            ))
        .get();
  }

  @override
  Future<List<CategoryItem>> getAllExpenses() {
    var query = select(categories)..where((c) => c.isAnIncome.equals(false));
    return query
        .map((row) => CategoryItem(
              id: row.id,
              isAnIncome: row.isAnIncome,
              name: row.name,
              icon: row.icon,
              iconColor: row.iconColor,
            ))
        .get();
  }
}
