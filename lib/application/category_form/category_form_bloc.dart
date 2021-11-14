import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/extensions/string_extensions.dart';
import 'package:my_expenses/domain/models/entities/daos/categories_dao.dart';
import 'package:my_expenses/domain/models/entities/daos/users_dao.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/domain/services/services.dart';
import 'package:my_expenses/presentation/shared/utils/category_utils.dart';

part 'category_form_bloc.freezed.dart';
part 'category_form_event.dart';
part 'category_form_state.dart';

class CategoryFormBloc extends Bloc<CategoryFormEvent, CategoryState> {
  final LoggingService _logger;
  final CategoriesDao _categoriesDao;
  final UsersDao _usersDao;

  _LoadedState get currentState => state as _LoadedState;

  static int maxNameLength = 30;

  CategoryFormBloc(this._logger, this._categoriesDao, this._usersDao) : super(const CategoryState.loading());

  @override
  Stream<CategoryState> mapEventToState(CategoryFormEvent event) async* {
    try {
      final s = await event.map(
        addCategory: (_) async => CategoryState.loaded(
          id: 0,
          name: '',
          isNameValid: false,
          isNameDirty: false,
          type: TransactionType.incomes,
          isTypeValid: true,
          icon: CategoryUtils.getByName(CategoryUtils.question).icon.icon!,
          isIconValid: true,
          iconColor: Colors.white,
          isFormValid: false,
          isNew: true,
        ),
        editCategory: (e) async => CategoryState.loaded(
          id: e.category.id,
          name: e.category.name,
          isNameValid: true,
          type: e.category.isAnIncome ? TransactionType.incomes : TransactionType.expenses,
          isTypeValid: true,
          icon: e.category.icon!,
          isIconValid: true,
          iconColor: e.category.iconColor!,
          isFormValid: true,
          isNew: false,
          isNameDirty: false,
        ),
        nameChanged: (e) async => state.map(
          loading: (state) => state,
          loaded: (state) => state.copyWith(name: e.name, isNameValid: isNameValid(e.name), isNameDirty: true),
        ),
        typeChanged: (e) async => state.map(
          loading: (state) => state,
          loaded: (state) => state.copyWith(type: e.selectedType, isTypeValid: true),
        ),
        iconChanged: (e) async => state.map(
          loading: (state) => state,
          loaded: (state) => state.copyWith(icon: e.selectedIcon, isIconValid: true),
        ),
        iconColorChanged: (e) async => state.map(
          loading: (state) => state,
          loaded: (state) => state.copyWith(iconColor: e.iconColor),
        ),
        deleteCategory: (e) async => _deleteCategory(),
        formSubmitted: (e) async => _saveCategory(),
      );

      yield s;

      if (state is _LoadedState && currentState.categoryCantBeDeleted) {
        yield currentState.copyWith.call(categoryCantBeDeleted: false);
      }
    } catch (e, s) {
      _logger.error(runtimeType, 'An unknown error occurred', e, s);
      if (state is _LoadedState) {
        yield currentState.copyWith.call(errorOccurred: true);
        yield currentState.copyWith.call(errorOccurred: false, categoryCantBeDeleted: false);
      }
    }
  }

  bool isNameValid(String name) => !name.isNullOrEmpty(minLength: 1, maxLength: maxNameLength);

  bool isFormValid() => currentState.isNameValid && currentState.isTypeValid && currentState.isIconValid;

  Future<CategoryState> _saveCategory() async {
    final category = _buildCategoryItem();
    _logger.info(runtimeType, '_saveCategory: Trying to save category = ${category.toJson()}');
    final currentUser = await _usersDao.getActiveUser();
    final savedCategory = await _categoriesDao.saveCategory(currentUser?.id, category);
    return currentState.copyWith.call(
      id: savedCategory.id,
      icon: savedCategory.icon!,
      type: savedCategory.isAnIncome ? TransactionType.incomes : TransactionType.expenses,
      name: savedCategory.name,
      iconColor: savedCategory.iconColor!,
      saved: true,
    );
  }

  Future<CategoryState> _deleteCategory() async {
    final category = _buildCategoryItem();
    _logger.info(runtimeType, '_deleteCategory: Trying to delete categoryId = ${category.id}');
    final isBeingUsed = await _categoriesDao.isCategoryBeingUsed(category.id);

    if (!isBeingUsed) {
      await _categoriesDao.deleteCategory(category.id);
      return currentState.copyWith.call(deleted: true);
    } else {
      return currentState.copyWith(categoryCantBeDeleted: true);
    }
  }

  CategoryItem _buildCategoryItem() {
    return CategoryItem(
      icon: currentState.icon,
      iconColor: currentState.iconColor,
      id: currentState.id,
      isAnIncome: currentState.type == TransactionType.incomes,
      name: currentState.name.trim(),
    );
  }
}
