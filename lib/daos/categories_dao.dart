import '../models/category_item.dart';

abstract class CategoriesDao {
  Future<List<CategoryItem>> getAll();

  Future<List<CategoryItem>> getAllCategories(bool onlyIncomes);

  Future<List<CategoryItem>> getAllIncomes();

  Future<List<CategoryItem>> getAllExpenses();

  Future<CategoryItem> saveCategory(CategoryItem category);

  Future<bool> deleteCategory(int id);
}
