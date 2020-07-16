import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../daos/categories_dao.dart';
import '../../daos/users_dao.dart';
import '../../models/category_item.dart';
import '../../services/logging_service.dart';

part 'categories_list_event.dart';
part 'categories_list_state.dart';

abstract class _CategoriesListBloc extends Bloc<CategoriesListEvent, CategoriesListState> {
  final LoggingService _logger;
  final CategoriesDao _categoriesDao;
  final UsersDao _usersDao;

  _CategoriesListBloc(this._logger, this._categoriesDao, this._usersDao) : super(CategoriesLoadingState());

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
    try {
      _logger.info(
        runtimeType,
        '_loadCategories: Trying to get all the ${event.loadIncomes ? "incomes" : "expenses"} categories',
      );
      final currentUser = await _usersDao.getActiveUser();
      final categories = await _categoriesDao.getAllCategories(
        event.loadIncomes,
        currentUser?.id,
      );

      if (event.selectedCategory != null && categories.any((t) => t.id == event.selectedCategory.id)) {
        _setSelectedItem(event.selectedCategory.id, categories);
      }
      yield buildCategoriesLoadedState(categories);
    } catch (e, s) {
      _logger.error(
        runtimeType,
        '_loadCategories: Unknown error occurred',
        e,
        s,
      );
      yield buildCategoriesLoadedState([]);
    }
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
    final categories = List<CategoryItem>.generate(currentState.categories.length, (i) {
      return currentState.categories[i].copyWith(isSeleted: false);
    });

    return categories;
  }

  void _setSelectedItem(int selectedId, List<CategoryItem> categories) {
    _logger.info(runtimeType, '_setSelectedItem: Setting the selected categoryId = $selectedId');

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
  IncomesCategoriesBloc(
    LoggingService logger,
    CategoriesDao categoriesDao,
    UsersDao usersDao,
  ) : super(logger, categoriesDao, usersDao);

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
  ExpensesCategoriesBloc(
    LoggingService logger,
    CategoriesDao categoriesDao,
    UsersDao usersDao,
  ) : super(logger, categoriesDao, usersDao);

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
