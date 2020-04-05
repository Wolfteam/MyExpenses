import '../common/enums/local_status_type.dart';
import '../models/category_item.dart';
import '../models/drive/category.dart' as sync_cat;

abstract class CategoriesDao {
  Future<List<CategoryItem>> getAll(int userId);

  Future<List<CategoryItem>> getAllCategories(bool onlyIncomes, int userId);

  Future<List<CategoryItem>> getAllIncomes(int userId);

  Future<List<CategoryItem>> getAllExpenses(int userId);

  Future<CategoryItem> saveCategory(int userId, CategoryItem category);

  Future<bool> deleteCategory(int id);

  Future<bool> isCategoryBeingUsed(int id);

  Future<void> updateUserId(int userId);

  Future<void> deleteAll();

  Future<List<sync_cat.Category>> getAllCategoriesToSync(int userId);

  Future<void> syncDownDelete(
    int userId,
    List<sync_cat.Category> existingCats,
  );

  Future<void> syncUpDelete(int userId);

  Future<void> syncDownCreate(
    int userId,
    List<sync_cat.Category> existingCats,
  );

  Future<void> syncDownUpdate(
    int userId,
    List<sync_cat.Category> existingCats,
  );

  Future<void> updateAllLocalStatus(LocalStatusType newValue);
}
