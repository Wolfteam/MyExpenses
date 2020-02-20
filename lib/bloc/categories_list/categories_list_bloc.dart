import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../models/category_item.dart';
import '../../models/entities/database.dart';

part 'categories_list_event.dart';
part 'categories_list_state.dart';

abstract class _CategoriesListBloc
    extends Bloc<CategoriesListEvent, CategoriesListState> {
  final AppDatabase _db;

  _CategoriesListBloc(this._db);

  @override
  CategoriesListState get initialState => CategoriesLoadingState();

  CategoriesLoadedState get currentState => state as CategoriesLoadedState;

  @override
  Stream<CategoriesListState> mapEventToState(
    CategoriesListEvent event,
  ) async* {
    if (event is GetCategories) {
      yield* _loadCategories(event);
    }

    if (event is CategoryWasSelected &&
        state is CategoriesLoadedState &&
        currentState.categories.any((c) => c.id == event.selectedCategory.id)) {
      yield* _categorySelected(event);
    }

    if (event is UnSelectAllCategories && state is CategoriesLoadedState) {
      final categories = _changeSelectedState(false);
      yield currentState.copyWith(categories: categories);
    }
  }

  Stream<CategoriesLoadedState> _loadCategories(GetCategories event) async* {
    final categories =
        await _db.categoriesDao.getAllCategories(event.loadIncomes);

    if (event.selectedCategory != null &&
        categories.any((t) => t.id == event.selectedCategory.id)) {
      _setSelectedItem(event.selectedCategory.id, categories);
    }
    yield buildCategoriesLoadedState(categories);
  }

  Stream<CategoriesLoadedState> _categorySelected(
    CategoryWasSelected event,
  ) async* {
    final categories = _changeSelectedState(false);

    _setSelectedItem(event.selectedCategory.id, categories);

    yield currentState.copyWith(
      categories: categories,
    );
  }

  List<CategoryItem> _changeSelectedState(bool isSelected) {
    final categories =
        List<CategoryItem>.generate(currentState.categories.length, (i) {
      return currentState.categories[i].copyWith(isSeleted: false);
    });

    return categories;
  }

  void _setSelectedItem(int selectedId, List<CategoryItem> categories) {
    final int index = categories.indexWhere((t) => t.id == selectedId);
    final cat = categories.elementAt(index).copyWith(isSeleted: true);
    categories.insert(index, cat);
    categories.removeAt(index + 1);
  }

  CategoriesLoadedState buildCategoriesLoadedState(
    List<CategoryItem> categories,
  );
}

class IncomesCategoriesBloc extends _CategoriesListBloc {
  IncomesCategoriesBloc(AppDatabase db) : super(db);

  @override
  CategoriesLoadedState buildCategoriesLoadedState(
    List<CategoryItem> categories,
  ) {
    return CategoriesLoadedState(
      loadedIncomes: true,
      categories: categories,
    );
  }
}

class ExpensesCategoriesBloc extends _CategoriesListBloc {
  ExpensesCategoriesBloc(AppDatabase db) : super(db);

  @override
  CategoriesLoadedState buildCategoriesLoadedState(
    List<CategoryItem> categories,
  ) {
    return CategoriesLoadedState(
      loadedIncomes: false,
      categories: categories,
    );
  }
}
