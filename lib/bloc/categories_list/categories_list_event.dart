part of 'categories_list_bloc.dart';

@immutable
abstract class CategoriesListEvent extends Equatable {
  const CategoriesListEvent();

  @override
  List<Object> get props => [];
}

class GetCategories extends CategoriesListEvent {
  final bool loadIncomes;
  final CategoryItem selectedCategory;

  const GetCategories({@required this.loadIncomes, this.selectedCategory});

  @override
  List<Object> get props => [loadIncomes, selectedCategory];
}

class CategoryWasSelected extends CategoriesListEvent {
  final bool wasSelected;
  final CategoryItem selectedCategory;

  const CategoryWasSelected({
    @required this.wasSelected,
    @required this.selectedCategory,
  });

  @override
  List<Object> get props => [wasSelected, selectedCategory];
}

class UnSelectAllCategories extends CategoriesListEvent {}
