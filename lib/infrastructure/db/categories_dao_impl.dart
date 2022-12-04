import 'package:drift/drift.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/models/drive.dart' as drive;
import 'package:my_expenses/domain/models/entities.dart';
import 'package:my_expenses/domain/models/entities/converters/db_converters.dart';
import 'package:my_expenses/domain/models/entities/daos/categories_dao.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/infrastructure/db/database.dart';

part 'categories_dao_impl.g.dart';

@DriftAccessor(tables: [Categories, Transactions])
class CategoriesDaoImpl extends DatabaseAccessor<AppDatabase> with _$CategoriesDaoImplMixin implements CategoriesDao {
  CategoriesDaoImpl(AppDatabase db) : super(db);

  @override
  Future<List<CategoryItem>> getAll(int? userId) {
    final query = select(categories)..orderBy([(t) => OrderingTerm(expression: t.name)]);

    if (userId != null) {
      query.where(
        (c) => c.userId.equals(userId) & c.localStatus.equals(LocalStatusType.deleted.index).not(),
      );
    } else {
      query.where(
        (c) => c.userId.isNull() & c.localStatus.equals(LocalStatusType.deleted.index).not(),
      );
    }

    return query
        .map(
          (row) => CategoryItem(
            id: row.id,
            isAnIncome: row.isAnIncome,
            name: row.name,
            icon: row.icon,
            iconColor: row.iconColor,
          ),
        )
        .get();
  }

  @override
  Future<List<CategoryItem>> getAllCategories(bool onlyIncomes, int? userId) {
    if (onlyIncomes) return getAllIncomes(userId);
    return getAllExpenses(userId);
  }

  @override
  Future<List<CategoryItem>> getAllIncomes(int? userId) async {
    final query = select(categories);

    if (userId != null) {
      query.where(
        (c) => c.isAnIncome.equals(true) & c.userId.equals(userId) & c.localStatus.equals(LocalStatusType.deleted.index).not(),
      );
    } else {
      query.where(
        (c) => c.isAnIncome.equals(true) & c.userId.isNull() & c.localStatus.equals(LocalStatusType.deleted.index).not(),
      );
    }

    return (query..orderBy([(t) => OrderingTerm(expression: t.name)])).map(_mapToCategoryItem).get();
  }

  @override
  Future<List<CategoryItem>> getAllExpenses(int? userId) {
    final query = select(categories)..orderBy([(t) => OrderingTerm(expression: t.name)]);

    if (userId != null) {
      query.where(
        (c) => c.isAnIncome.equals(false) & c.userId.equals(userId) & c.localStatus.equals(LocalStatusType.deleted.index).not(),
      );
    } else {
      query.where(
        (c) => c.isAnIncome.equals(false) & c.userId.isNull() & c.localStatus.equals(LocalStatusType.deleted.index).not(),
      );
    }
    return query.map(_mapToCategoryItem).get();
  }

  @override
  Future<CategoryItem> saveCategory(int? userId, CategoryItem category) async {
    Category savedCategory;
    int id = 0;
    final now = DateTime.now();
    if (category.id <= 0) {
      id = await into(categories).insert(
        CategoriesCompanion.insert(
          localStatus: LocalStatusType.created,
          userId: Value(userId),
          icon: Value(category.icon),
          iconColor: category.iconColor!,
          isAnIncome: category.isAnIncome,
          name: category.name,
          createdAt: now,
          createdBy: createdBy,
          createdHash: createdHash([
            category.name,
            now,
            createdBy,
            category.isAnIncome,
            const ColorConverter().toSql(category.iconColor),
            const IconDataConverter().toSql(category.icon) ?? '',
          ]),
        ),
      );
    } else {
      id = category.id;
      final currentCat = await (select(categories)..where((c) => c.id.equals(id))).getSingle();

      final updatedFields = CategoriesCompanion(
        icon: Value(category.icon),
        iconColor: Value(category.iconColor!),
        isAnIncome: Value(category.isAnIncome),
        name: Value(category.name),
        updatedAt: Value(DateTime.now()),
        updatedBy: const Value(createdBy),
        userId: Value(userId),
        localStatus: currentCat.localStatus == LocalStatusType.created ? const Value(LocalStatusType.created) : const Value(LocalStatusType.updated),
      );

      await (update(categories)..where((t) => t.id.equals(id))).write(updatedFields);
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
    final cat = await (select(categories)..where((c) => c.id.equals(id))).getSingle();

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
    return (update(categories)..where((c) => c.userId.isNull())).write(CategoriesCompanion(userId: Value(userId)));
  }

  @override
  Future<void> onUserSignedOut() {
    return update(categories).write(const CategoriesCompanion(userId: Value(null)));
  }

  @override
  Future<void> deleteAll(int? userId) {
    if (userId == null) {
      return (delete(categories)..where((c) => c.userId.isNull())).go();
    }
    return (delete(categories)..where((c) => c.userId.equals(userId))).go();
  }

  @override
  Future<List<drive.Category>> getAllCategoriesToSync(int userId) {
    return (select(categories)
          ..where(
            (c) => c.localStatus.equals(LocalStatusType.deleted.index).not() & c.userId.equals(userId),
          )
          ..orderBy(
            [(c) => OrderingTerm(expression: c.id)],
          ))
        .map(
          (row) => drive.Category(
            createdAt: row.createdAt,
            createdBy: row.createdBy,
            createdHash: row.createdHash,
            icon: const IconDataConverter().toSql(row.icon)!,
            iconColor: const ColorConverter().toSql(row.iconColor),
            isAnIncome: row.isAnIncome,
            name: row.name,
            updatedAt: row.updatedAt,
            updatedBy: row.updatedBy,
          ),
        )
        .get();
  }

  @override
  Future<void> syncDownDelete(
    int userId,
    List<drive.Category> existingCats,
  ) async {
    final catsInDb = await (select(categories)
          ..where(
            (c) => c.userId.equals(userId) & c.localStatus.equals(LocalStatusType.created.index).not(),
          ))
        .get();
    final downloadedCatsHash = existingCats.map((c) => c.createdHash).toList();
    final catsToDelete = catsInDb.where((c) => !downloadedCatsHash.contains(c.createdHash)).map((t) => t.id).toList();

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
            (c) => c.localStatus.equals(LocalStatusType.deleted.index) & c.userId.equals(userId),
          ))
        .go();
  }

  @override
  Future<void> syncDownCreate(
    int userId,
    List<drive.Category> existingCats,
  ) async {
    final catsInDb = await (select(categories)..where((c) => c.userId.equals(userId))).get();
    final localCatsHash = catsInDb.map((c) => c.createdHash).toList();
    final catsToBeCreated = existingCats
        .where((c) => !localCatsHash.contains(c.createdHash))
        .map(
          (c) => CategoriesCompanion.insert(
            localStatus: LocalStatusType.nothing,
            createdAt: c.createdAt,
            createdBy: c.createdBy,
            createdHash: c.createdHash,
            icon: Value(const IconDataConverter().fromSql(c.icon)),
            iconColor: const ColorConverter().fromSql(c.iconColor),
            isAnIncome: c.isAnIncome,
            name: c.name,
            updatedAt: Value(c.updatedAt),
            updatedBy: Value(c.updatedBy),
            userId: Value(userId),
          ),
        )
        .toList();

    if (catsToBeCreated.isEmpty) return;

    await batch((b) {
      b.insertAll(categories, catsToBeCreated);
    });
  }

  @override
  Future<void> syncDownUpdate(
    int userId,
    List<drive.Category> existingCats,
  ) async {
    final existingCatsToUse = existingCats.where((t) => t.updatedAt != null).toList();
    final downloadedCatsHash = existingCatsToUse.map((c) => c.createdHash).toList();
    final catsInDb = await (select(categories)
          ..where(
            (c) => c.userId.equals(userId) & c.createdHash.isIn(downloadedCatsHash) & c.localStatus.equals(LocalStatusType.deleted.index).not(),
          ))
        .get();

    final catsToUpdate = <Category>[];
    for (final cat in catsToUpdate) {
      final localCat = catsInDb.singleWhere((t) => t.createdHash == cat.createdHash);

      if (localCat.updatedAt == null || localCat.updatedAt!.isBefore(cat.updatedAt!)) {
        catsToUpdate.add(localCat);
      }
    }

    if (catsToUpdate.isEmpty) return;

    await batch((b) {
      for (final cat in catsToUpdate) {
        final updatedCat = existingCatsToUse.singleWhere((c) => c.createdHash == cat.createdHash);

        b.update<Categories, Category>(
          categories,
          CategoriesCompanion(
            localStatus: const Value(LocalStatusType.nothing),
            icon: Value(const IconDataConverter().fromSql(updatedCat.icon)),
            iconColor: Value(
              const ColorConverter().fromSql(updatedCat.iconColor),
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
    return update(categories).write(
      CategoriesCompanion(
        updatedAt: Value(DateTime.now()),
        updatedBy: const Value(createdBy),
        localStatus: Value(newValue),
      ),
    );
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
