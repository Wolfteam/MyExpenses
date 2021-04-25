import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meta/meta.dart';

import '../../daos/categories_dao.dart';
import '../../daos/users_dao.dart';
import '../../models/category_item.dart';
import '../../services/logging_service.dart';

part 'categories_list_bloc.freezed.dart';
part 'categories_list_event.dart';
part 'categories_list_state.dart';

abstract class _CategoriesListBloc extends Bloc<CategoriesListEvent, CategoriesListState> {
  final LoggingService _logger;
  final CategoriesDao _categoriesDao;
  final UsersDao _usersDao;

  _CategoriesListBloc(this._logger, this._categoriesDao, this._usersDao) : super(const CategoriesListState.loading());

  _LoadedState get currentState => state as _LoadedState;

  @override
  Stream<CategoriesListState> mapEventToState(
    CategoriesListEvent event,
  ) async* {
    final s = await event.map(
      getCategories: (e) async => _loadCategories(e),
      categoryWasSelected: (e) async => _categorySelected(e),
      unSelectAll: (_) async {
        final categories = _changeSelectedState(false);
        return currentState.copyWith.call(categories: categories);
      },
    );

    yield s;
  }

  Future<CategoriesListState> _loadCategories(_GetCategories event) async {
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

      if (event.selectedCategory != null && categories.any((t) => t.id == event.selectedCategory!.id)) {
        _setSelectedItem(event.selectedCategory!.id, categories);
      }
      return buildCategoriesLoadedState(categories);
    } catch (e, s) {
      _logger.error(
        runtimeType,
        '_loadCategories: Unknown error occurred',
        e,
        s,
      );
      return buildCategoriesLoadedState([]);
    }
  }

  CategoriesListState _categorySelected(_CategoryWasSelected event) {
    final categories = _changeSelectedState(false);

    _setSelectedItem(event.selectedCategory.id, categories);

    return currentState.copyWith(categories: categories);
  }

  List<CategoryItem> _changeSelectedState(bool isSelected) {
    final categories = List<CategoryItem>.generate(currentState.categories.length, (i) {
      return currentState.categories[i].copyWith();
    });

    return categories;
  }

  void _setSelectedItem(int selectedId, List<CategoryItem> categories) {
    _logger.info(runtimeType, '_setSelectedItem: Setting the selected categoryId = $selectedId');

    final int index = categories.indexWhere((t) => t.id == selectedId);
    final cat = categories.elementAt(index).copyWith(isSelected: true);
    categories.insert(index, cat);
    categories.removeAt(index + 1);
  }

  CategoriesListState buildCategoriesLoadedState(
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
  CategoriesListState buildCategoriesLoadedState(List<CategoryItem> categories) {
    return CategoriesListState.loaded(loadedIncomes: true, categories: categories);
  }
}

class ExpensesCategoriesBloc extends _CategoriesListBloc {
  ExpensesCategoriesBloc(
    LoggingService logger,
    CategoriesDao categoriesDao,
    UsersDao usersDao,
  ) : super(logger, categoriesDao, usersDao);

  @override
  CategoriesListState buildCategoriesLoadedState(List<CategoryItem> categories) {
    return CategoriesListState.loaded(loadedIncomes: false, categories: categories);
  }
}
