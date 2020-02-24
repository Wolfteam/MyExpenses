part of '../models/entities/database.dart';

@UseDao(tables: [Categories])
class CategoriesDaoImpl extends DatabaseAccessor<AppDatabase>
    with _$CategoriesDaoImplMixin
    implements CategoriesDao {
  CategoriesDaoImpl(AppDatabase db) : super(db);

  @override
  Future<List<CategoryItem>> getAll() {
    return (select(categories)
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
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
  Future<List<CategoryItem>> getAllCategories(bool onlyIncomes) {
    if (onlyIncomes) return getAllIncomes();
    return getAllExpenses();
  }

  @override
  Future<List<CategoryItem>> getAllIncomes() {
    final query = select(categories)
      ..where((c) => c.isAnIncome.equals(true))
      ..orderBy([(t) => OrderingTerm(expression: t.name)]);
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
    final query = select(categories)
      ..where((c) => c.isAnIncome.equals(false))
      ..orderBy([(t) => OrderingTerm(expression: t.name)]);
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
  Future<CategoryItem> saveCategory(CategoryItem category) async {
    Category savedCategory;
    int id = 0;

    if (category.id <= 0) {
      id = await into(categories).insert(Category(
        createdBy: 'someone',
        icon: category.icon,
        iconColor: category.iconColor,
        isAnIncome: category.isAnIncome,
        name: category.name,
      ));
    } else {
      id = category.id;
      final updatedFields = CategoriesCompanion(
        icon: Value(category.icon),
        iconColor: Value(category.iconColor),
        isAnIncome: Value(category.isAnIncome),
        name: Value(category.name),
        updatedAt: Value(DateTime.now()),
        updatedBy: Value('somebody'),
      );

      await (update(categories)..where((t) => t.id.equals(id)))
          .write(updatedFields);
    }

    final query = select(categories)..where((t) => t.id.equals(id));
    savedCategory = (await query.get()).first;

    return CategoryItem(
      icon: savedCategory.icon,
      iconColor: savedCategory.iconColor,
      id: savedCategory.id,
      isAnIncome: savedCategory.isAnIncome,
      name: savedCategory.name,
    );
  }

  @override
  Future<bool> deleteCategory(int id) async {
    await (delete(categories)..where((t) => t.id.equals(id))).go();
    return true;
  }
}
