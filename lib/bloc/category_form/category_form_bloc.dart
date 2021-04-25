import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../common/enums/transaction_type.dart';
import '../../common/extensions/string_extensions.dart';
import '../../common/utils/category_utils.dart';
import '../../daos/categories_dao.dart';
import '../../daos/users_dao.dart';
import '../../models/category_item.dart';
import '../../services/logging_service.dart';

part 'category_form_bloc.freezed.dart';
part 'category_form_event.dart';
part 'category_form_state.dart';

CategoryState _initialState() {
  final cat = CategoryUtils.getByName(CategoryUtils.question);
  return CategoryState.initial(
    id: 0,
    name: '',
    isNameValid: false,
    isNameDirty: false,
    type: TransactionType.incomes,
    isTypeValid: true,
    icon: cat.icon.icon!,
    isIconValid: true,
    iconColor: Colors.white,
  );
}

class CategoryFormBloc extends Bloc<CategoryFormEvent, CategoryState> {
  final LoggingService _logger;
  final CategoriesDao _categoriesDao;
  final UsersDao _usersDao;

  CategoryFormBloc(this._logger, this._categoriesDao, this._usersDao) : super(_initialState());

  _InitialState get currentState => state as _InitialState;

  @override
  Stream<CategoryState> mapEventToState(
    CategoryFormEvent event,
  ) async* {
    try {
      final s = await event.map(
        addCategory: (_) async => _initialState(),
        editCategory: (e) async => currentState.copyWith(
          id: e.category.id,
          name: e.category.name,
          isNameValid: true,
          type: e.category.isAnIncome ? TransactionType.incomes : TransactionType.expenses,
          isTypeValid: true,
          icon: e.category.icon!,
          isIconValid: true,
          iconColor: e.category.iconColor!,
        ),
        nameChanged: (e) async => currentState.copyWith(
          name: e.name,
          isNameValid: isNameValid(e.name),
          isNameDirty: true,
        ),
        typeChanged: (e) async => currentState.copyWith(
          type: e.selectedType,
          isTypeValid: true,
        ),
        iconChanged: (e) async => currentState.copyWith(
          icon: e.selectedIcon,
          isIconValid: true,
        ),
        iconColorChanged: (e) async => currentState.copyWith(iconColor: e.iconColor),
        deleteCategory: (e) async => _deleteCategory(),
        formSubmitted: (e) async => _saveCategory(),
        formClosed: (_) async => _initialState(),
      );

      yield s;
      yield currentState.copyWith(categoryCantBeDeleted: false);
    } catch (e, s) {
      _logger.error(runtimeType, 'An unknown error occurred', e, s);
      yield currentState.copyWith(errorOccurred: true);
      yield currentState.copyWith(errorOccurred: false);
    }
  }

  bool isNameValid(String name) => !name.isNullOrEmpty(minLength: 1);

  Future<CategoryState> _saveCategory() async {
    final category = _buildCategoryItem();
    _logger.info(runtimeType, '_saveCategory: Trying to save category = ${category.toJson()}');
    final currentUser = await _usersDao.getActiveUser();
    final savedCategory = await _categoriesDao.saveCategory(
      currentUser?.id,
      category,
    );
    return CategoryState.saved(category: savedCategory);
  }

  Future<CategoryState> _deleteCategory() async {
    final category = _buildCategoryItem();
    _logger.info(runtimeType, '_deleteCategory: Trying to delete categoryId = ${category.id}');
    final isBeingUsed = await _categoriesDao.isCategoryBeingUsed(category.id);

    if (!isBeingUsed) {
      await _categoriesDao.deleteCategory(category.id);
      return CategoryState.deleted(category: category);
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
