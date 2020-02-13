import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:my_expenses/models/category_item.dart';
import 'package:my_expenses/models/entities/database.dart';

part 'categories_list_event.dart';
part 'categories_list_state.dart';

class CategoriesListBloc
    extends Bloc<CategoriesListEvent, CategoriesListState> {
  final AppDatabase db;

  CategoriesListBloc(this.db);

  @override
  CategoriesListState get initialState => CategoriesListInitialState();

  @override
  Stream<CategoriesListState> mapEventToState(
    CategoriesListEvent event,
  ) async* {
    yield CategoriesLoadingState();

    if (event is GetCategories) {
      var categories = await db.categoriesDao.getAllCategories(event.loadIncomes);
      yield CategoriesLoadedState(categories: categories);
    }
  }
}
