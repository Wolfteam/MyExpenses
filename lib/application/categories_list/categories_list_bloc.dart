import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/domain/models/entities/daos/categories_dao.dart';
import 'package:my_expenses/domain/models/entities/daos/users_dao.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/domain/services/services.dart';

part 'categories_list_bloc.freezed.dart';
part 'categories_list_event.dart';
part 'categories_list_state.dart';

abstract class _CategoriesListBloc extends Bloc<CategoriesListEvent, CategoriesListState> {
  final LoggingService _logger;
  final CategoriesDao _categoriesDao;
  final UsersDao _usersDao;

  _CategoriesListBloc(this._logger, this._categoriesDao, this._usersDao) : super(const CategoriesListState.loading()) {
    on<CategoriesListEventGetCategories>((event, emit) async {
      final s = await _loadCategories(event);
      emit(s);
    });

    on<CategoriesListEventCategoryWasSelected>((event, emit) {
      final s = _categorySelected(event);
      emit(s);
    });

    on<CategoriesListEventUnselectAll>((event, emit) {
      if (state is! CategoriesListStateLoadedState) {
        return;
      }
      final categories = _changeSelectedState(false);
      final s = currentState.copyWith.call(categories: categories);
      emit(s);
    });
  }

  CategoriesListStateLoadedState get currentState => state as CategoriesListStateLoadedState;

  Future<CategoriesListState> _loadCategories(CategoriesListEventGetCategories event) async {
    try {
      _logger.info(
        runtimeType,
        '_loadCategories: Trying to get all the ${event.loadIncomes ? "incomes" : "expenses"} categories',
      );
      final currentUser = await _usersDao.getActiveUser();
      final categories = await _categoriesDao.getAllCategories(event.loadIncomes, currentUser?.id);

      if (event.selectedCategory != null && categories.any((t) => t.id == event.selectedCategory!.id)) {
        _setSelectedItem(event.selectedCategory!.id, categories);
      }
      return buildCategoriesLoadedState(categories);
    } catch (e, s) {
      _logger.error(runtimeType, '_loadCategories: Unknown error occurred', e, s);
      return buildCategoriesLoadedState([]);
    }
  }

  CategoriesListState _categorySelected(CategoriesListEventCategoryWasSelected event) {
    if (state is! CategoriesListStateLoadedState || !currentState.categories.any((c) => c.id == event.selectedCategory.id)) {
      return state;
    }

    final categories = _changeSelectedState(false);

    _setSelectedItem(event.selectedCategory.id, categories);

    return currentState.copyWith(categories: categories);
  }

  List<CategoryItem> _changeSelectedState(bool isSelected) {
    final categories = List<CategoryItem>.generate(currentState.categories.length, (i) {
      return currentState.categories[i].copyWith.call(isSelected: isSelected);
    });

    return categories;
  }

  void _setSelectedItem(int selectedId, List<CategoryItem> categories) {
    _logger.info(runtimeType, '_setSelectedItem: Setting the selected categoryId = $selectedId');

    final int index = categories.indexWhere((t) => t.id == selectedId);
    final cat = categories.elementAt(index).copyWith.call(isSelected: true);
    categories.insert(index, cat);
    categories.removeAt(index + 1);
  }

  CategoriesListState buildCategoriesLoadedState(List<CategoryItem> categories);
}

class IncomesCategoriesBloc extends _CategoriesListBloc {
  IncomesCategoriesBloc(super.logger, super.categoriesDao, super.usersDao);

  @override
  CategoriesListState buildCategoriesLoadedState(List<CategoryItem> categories) {
    return CategoriesListState.loaded(loadedIncomes: true, categories: categories);
  }
}

class ExpensesCategoriesBloc extends _CategoriesListBloc {
  ExpensesCategoriesBloc(super.logger, super.categoriesDao, super.usersDao);

  @override
  CategoriesListState buildCategoriesLoadedState(List<CategoryItem> categories) {
    return CategoriesListState.loaded(loadedIncomes: false, categories: categories);
  }
}
