part of 'categories_list_bloc.dart';

@immutable
abstract class CategoriesListState extends Equatable {
  @override
  List<Object> get props => [];
}

class CategoriesLoadingState extends CategoriesListState {}

class CategoriesLoadedState extends CategoriesListState {
  final bool loadedIncomes;
  final List<CategoryItem> categories;

  CategoriesLoadedState({
    @required this.loadedIncomes,
    @required this.categories,
  });

  @override
  List<Object> get props => [loadedIncomes, categories];

  CategoriesLoadedState copyWith({
    bool loadedIncomes,
    List<CategoryItem> categories,
  }) {
    return CategoriesLoadedState(
      loadedIncomes: loadedIncomes ?? this.loadedIncomes,
      categories: categories ?? this.categories,
    );
  }
}

class CategoriesSelectedState extends CategoriesLoadedState {
  CategoriesSelectedState({
    @required bool loadedIncomes,
    @required List<CategoryItem> categories,
  }) : super(loadedIncomes: loadedIncomes, categories: categories);
}
