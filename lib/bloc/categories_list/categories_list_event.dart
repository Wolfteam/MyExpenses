part of 'categories_list_bloc.dart';

@immutable
abstract class CategoriesListEvent {
  const CategoriesListEvent();
}

class GetCategories extends CategoriesListEvent {
  final bool loadIncomes;

  const GetCategories({@required this.loadIncomes});
}