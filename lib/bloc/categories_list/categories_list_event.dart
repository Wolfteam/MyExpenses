part of 'categories_list_bloc.dart';

@freezed
class CategoriesListEvent with _$CategoriesListEvent {
  const factory CategoriesListEvent.getCategories({
    required bool loadIncomes,
    CategoryItem? selectedCategory,
  }) = _GetCategories;

  const factory CategoriesListEvent.categoryWasSelected({
    required bool wasSelected,
    required CategoryItem selectedCategory,
  }) = _CategoryWasSelected;

  const factory CategoriesListEvent.unSelectAll() = _UnselectAll;
}
