part of 'categories_list_bloc.dart';

@freezed
sealed class CategoriesListState with _$CategoriesListState {
  const factory CategoriesListState.loading() = CategoriesListStateLoadingState;

  const factory CategoriesListState.loaded({required bool loadedIncomes, required List<CategoryItem> categories}) =
      CategoriesListStateLoadedState;

  const factory CategoriesListState.selected({required bool loadedIncomes, required List<CategoryItem> categories}) =
      CategoriesListStateSelectedState;
}
