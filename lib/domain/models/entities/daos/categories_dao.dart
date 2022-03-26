import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/models/category_item.dart';
import 'package:my_expenses/domain/models/drive.dart' as drive;

abstract class CategoriesDao {
  Future<List<CategoryItem>> getAll(int? userId);

  Future<List<CategoryItem>> getAllCategories(bool onlyIncomes, int? userId);

  Future<List<CategoryItem>> getAllIncomes(int? userId);

  Future<List<CategoryItem>> getAllExpenses(int? userId);

  Future<CategoryItem> saveCategory(int? userId, CategoryItem category);

  Future<bool> deleteCategory(int id);

  Future<bool> isCategoryBeingUsed(int id);

  Future<void> updateUserId(int userId);

  Future<void> onUserSignedOut();

  Future<void> deleteAll(int? userId);

  Future<List<drive.Category>> getAllCategoriesToSync(int userId);

  Future<void> syncDownDelete(int userId, List<drive.Category> existingCats);

  Future<void> syncUpDelete(int userId);

  Future<void> syncDownCreate(int userId, List<drive.Category> existingCats);

  Future<void> syncDownUpdate(int userId, List<drive.Category> existingCats);

  Future<void> updateAllLocalStatus(LocalStatusType newValue);
}
