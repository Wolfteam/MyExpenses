part of 'categories_list_bloc.dart';

@freezed
sealed class CategoriesListEvent with _$CategoriesListEvent {
  const factory CategoriesListEvent.getCategories({required bool loadIncomes, CategoryItem? selectedCategory}) =
      CategoriesListEventGetCategories;

  const factory CategoriesListEvent.categoryWasSelected({required bool wasSelected, required CategoryItem selectedCategory}) =
      CategoriesListEventCategoryWasSelected;

  const factory CategoriesListEvent.unSelectAll() = CategoriesListEventUnselectAll;
}
