import '../models/category_item.dart';
import '../models/drive/category.dart' as sync_cat;

abstract class CategoriesDao {
  Future<List<CategoryItem>> getAll();

  Future<List<CategoryItem>> getAllCategories(bool onlyIncomes);

  Future<List<CategoryItem>> getAllIncomes();

  Future<List<CategoryItem>> getAllExpenses();

  Future<CategoryItem> saveCategory(CategoryItem category);

  Future<bool> deleteCategory(int id);

  Future<bool> isCategoryBeingUsed(int id);

  Future<void> updateUserId(int userId);

  Future<List<sync_cat.Category>> getAllCategoriesToSync();

  Future<void> deleteCategories(
    int userId,
    List<sync_cat.Category> existingCats,
  );

  Future<void> createCategories(
    int userId,
    List<sync_cat.Category> existingCats,
  );

  Future<void> updateCategories(
    int userId,
    List<sync_cat.Category> existingCats,
  );
}
