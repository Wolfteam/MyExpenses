part of '../models/entities/database.dart';

@UseDao(tables: [Categories, Transactions])
class CategoriesDaoImpl extends DatabaseAccessor<AppDatabase>
    with _$CategoriesDaoImplMixin
    implements CategoriesDao {
  CategoriesDaoImpl(AppDatabase db) : super(db);

  @override
  Future<List<CategoryItem>> getAll(int userId) {
    final query = select(categories)
      ..orderBy([(t) => OrderingTerm(expression: t.name)]);

    if (userId != null) {
      query.where(
        (c) =>
            c.userId.equals(userId) &
            c.localStatus.equals(LocalStatusType.deleted.index).not(),
      );
    } else {
      query.where(
        (c) =>
            isNull(c.userId) &
            c.localStatus.equals(LocalStatusType.deleted.index).not(),
      );
    }

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
  Future<List<CategoryItem>> getAllCategories(bool onlyIncomes, int userId) {
    if (onlyIncomes) return getAllIncomes(userId);
    return getAllExpenses(userId);
  }

  @override
  Future<List<CategoryItem>> getAllIncomes(int userId) async {
    final query = select(categories);

    if (userId != null) {
      query.where(
        (c) =>
            c.isAnIncome.equals(true) &
            c.userId.equals(userId) &
            c.localStatus.equals(LocalStatusType.deleted.index).not(),
      );
    } else {
      query.where(
        (c) =>
            c.isAnIncome.equals(true) &
            isNull(c.userId) &
            c.localStatus.equals(LocalStatusType.deleted.index).not(),
      );
    }

    return (query..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .map(_mapToCategoryItem)
        .get();
  }

  @override
  Future<List<CategoryItem>> getAllExpenses(int userId) {
    final query = select(categories)
      ..orderBy([(t) => OrderingTerm(expression: t.name)]);

    if (userId != null) {
      query.where(
        (c) =>
            c.isAnIncome.equals(false) &
            c.userId.equals(userId) &
            c.localStatus.equals(LocalStatusType.deleted.index).not(),
      );
    } else {
      query.where(
        (c) =>
            c.isAnIncome.equals(false) &
            isNull(c.userId) &
            c.localStatus.equals(LocalStatusType.deleted.index).not(),
      );
    }
    return query.map(_mapToCategoryItem).get();
  }

  @override
  Future<CategoryItem> saveCategory(int userId, CategoryItem category) async {
    Category savedCategory;
    int id = 0;
    final now = DateTime.now();
    if (category.id <= 0) {
      id = await into(categories).insert(Category(
        localStatus: LocalStatusType.created,
        userId: userId,
        icon: category.icon,
        iconColor: category.iconColor,
        isAnIncome: category.isAnIncome,
        name: category.name,
        createdAt: now,
        createdBy: createdBy,
        createdHash: createdHash([
          category.name,
          now,
          createdBy,
          category.isAnIncome,
          const ColorConverter().mapToSql(category.iconColor),
          const IconDataConverter().mapToSql(category.icon),
        ]),
      ));
    } else {
      id = category.id;
      final currentCat =
          await (select(categories)..where((c) => c.id.equals(id))).getSingle();

      final updatedFields = CategoriesCompanion(
        icon: Value(category.icon),
        iconColor: Value(category.iconColor),
        isAnIncome: Value(category.isAnIncome),
        name: Value(category.name),
        updatedAt: Value(DateTime.now()),
        updatedBy: const Value(createdBy),
        userId: Value(userId),
        localStatus: currentCat.localStatus == LocalStatusType.created
            ? const Value(LocalStatusType.created)
            : const Value(LocalStatusType.updated),
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
    final cat =
        await (select(categories)..where((c) => c.id.equals(id))).getSingle();

    if (cat.localStatus == LocalStatusType.created) {
      await (delete(categories)..where((t) => t.id.equals(id))).go();
      return true;
    }

    await (update(categories)..where((c) => c.id.equals(id))).write(
      CategoriesCompanion(
        updatedAt: Value(DateTime.now()),
        updatedBy: const Value(createdBy),
        localStatus: const Value(LocalStatusType.deleted),
      ),
    );
    return true;
  }

  @override
  Future<bool> isCategoryBeingUsed(int id) async {
    final query = select(transactions)..where((t) => t.categoryId.equals(id));
    final result = await query.get();
    return result.isNotEmpty;
  }

  @override
  Future<void> updateUserId(int userId) {
    return (update(categories)..where((c) => isNull(c.userId)))
        .write(CategoriesCompanion(userId: Value(userId)));
  }

  @override
  Future<void> onUserSignedOut() {
    return update(categories)
        .write(const CategoriesCompanion(userId: Value(null)));
  }

  @override
  Future<void> deleteAll() {
    return delete(categories).go();
  }

  @override
  Future<List<sync_cat.Category>> getAllCategoriesToSync(int userId) {
    return (select(categories)
          ..where(
            (c) => c.localStatus.equals(LocalStatusType.deleted.index).not(),
          )
          ..orderBy(
            [(c) => OrderingTerm(expression: c.id)],
          ))
        .map((row) => sync_cat.Category(
              createdAt: row.createdAt,
              createdBy: row.createdBy,
              createdHash: row.createdHash,
              icon: const IconDataConverter().mapToSql(row.icon),
              iconColor: const ColorConverter().mapToSql(row.iconColor),
              isAnIncome: row.isAnIncome,
              name: row.name,
              updatedAt: row.updatedAt,
              updatedBy: row.updatedBy,
            ))
        .get();
  }

  @override
  Future<void> syncDownDelete(
    int userId,
    List<sync_cat.Category> existingCats,
  ) async {
    final catsInDb = await (select(categories)
          ..where(
            (c) =>
                c.userId.equals(userId) &
                c.localStatus.equals(LocalStatusType.created.index).not(),
          ))
        .get();
    final downloadedCatsHash = existingCats.map((c) => c.createdHash).toList();
    final catsToDelete = catsInDb
        .where((c) => !downloadedCatsHash.contains(c.createdHash))
        .map((t) => t.id)
        .toList();

    if (catsToDelete.isEmpty) return;

    await batch((b) {
      b.deleteWhere<Categories, Category>(
        categories,
        (c) => c.id.isIn(catsToDelete),
      );
    });
  }

  @override
  Future<void> syncUpDelete(int userId) {
    return (delete(categories)
          ..where(
            (c) =>
                c.localStatus.equals(LocalStatusType.deleted.index) &
                c.userId.equals(userId),
          ))
        .go();
  }

  @override
  Future<void> syncDownCreate(
    int userId,
    List<sync_cat.Category> existingCats,
  ) async {
    final catsInDb =
        await (select(categories)..where((c) => c.userId.equals(userId))).get();
    final localCatsHash = catsInDb.map((c) => c.createdHash).toList();
    final catsToBeCreated = existingCats
        .where((c) => !localCatsHash.contains(c.createdHash))
        .map((c) => Category(
              localStatus: LocalStatusType.nothing,
              createdAt: c.createdAt,
              createdBy: c.createdBy,
              createdHash: c.createdHash,
              icon: const IconDataConverter().mapToDart(c.icon),
              iconColor: const ColorConverter().mapToDart(c.iconColor),
              isAnIncome: c.isAnIncome,
              name: c.name,
              updatedAt: c.updatedAt,
              updatedBy: c.updatedBy,
              userId: userId,
            ))
        .toList();

    if (catsToBeCreated.isEmpty) return;

    await batch((b) {
      b.insertAll<Category>(categories, catsToBeCreated);
    });
  }

  @override
  Future<void> syncDownUpdate(
    int userId,
    List<sync_cat.Category> existingCats,
  ) async {
    final existingCatsToUse =
        existingCats.where((t) => t.updatedAt != null).toList();
    final downloadedCatsHash =
        existingCatsToUse.map((c) => c.createdHash).toList();
    final catsInDb = await (select(categories)
          ..where(
            (c) =>
                c.userId.equals(userId) &
                c.createdHash.isIn(downloadedCatsHash) &
                c.localStatus.equals(LocalStatusType.deleted.index).not(),
          ))
        .get();

    final catsToUpdate = <Category>[];
    for (final cat in catsToUpdate) {
      final localCat =
          catsInDb.singleWhere((t) => t.createdHash == cat.createdHash);

      if (localCat.updatedAt == null ||
          localCat.updatedAt.isBefore(cat.updatedAt)) {
        catsToUpdate.add(localCat);
      }
    }

    if (catsToUpdate.isEmpty) return;

    await batch((b) {
      for (final cat in catsToUpdate) {
        final updatedCat = existingCatsToUse
            .singleWhere((c) => c.createdHash == cat.createdHash);

        b.update<Categories, Category>(
          categories,
          CategoriesCompanion(
            localStatus: const Value(LocalStatusType.nothing),
            icon: Value(const IconDataConverter().mapToDart(updatedCat.icon)),
            iconColor: Value(
              const ColorConverter().mapToDart(updatedCat.iconColor),
            ),
            isAnIncome: Value(updatedCat.isAnIncome),
            name: Value(updatedCat.name),
            updatedAt: Value(updatedCat.updatedAt),
            updatedBy: Value(updatedCat.updatedBy),
            userId: Value(userId),
          ),
          where: (c) => c.id.equals(cat.id),
        );
      }
    });
  }

  @override
  Future<void> updateAllLocalStatus(LocalStatusType newValue) {
    return update(categories).write(CategoriesCompanion(
      updatedAt: Value(DateTime.now()),
      updatedBy: const Value(createdBy),
      localStatus: Value(newValue),
    ));
  }

  CategoryItem _mapToCategoryItem(Category cat) {
    return CategoryItem(
      id: cat.id,
      isAnIncome: cat.isAnIncome,
      name: cat.name,
      icon: cat.icon,
      iconColor: cat.iconColor,
    );
  }
}
