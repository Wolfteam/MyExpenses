part of 'categories_list_bloc.dart';

@freezed
class CategoriesListState with _$CategoriesListState {
  const factory CategoriesListState.loading() = _LoadingState;

  const factory CategoriesListState.loaded({
    required bool loadedIncomes,
    required List<CategoryItem> categories,
  }) = _LoadedState;

  const factory CategoriesListState.selected({
    required bool loadedIncomes,
    required List<CategoryItem> categories,
  }) = _SelectedState;
}
