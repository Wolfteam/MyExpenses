part of 'categories_list_bloc.dart';

@immutable
abstract class CategoriesListState {}

class CategoriesListInitialState extends CategoriesListState {}

class CategoriesLoadingState extends CategoriesListState{

}

class CategoriesLoadedState extends CategoriesListState {
  final List<CategoryItem> categories;
  
  CategoriesLoadedState({
    this.categories,
  });

}
