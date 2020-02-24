import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../common/enums/transaction_type.dart';
import '../../common/extensions/string_extensions.dart';
import '../../common/utils/category_utils.dart';
import '../../daos/categories_dao.dart';
import '../../models/category_item.dart';

part 'category_form_event.dart';
part 'category_form_state.dart';

class CategoryFormBloc extends Bloc<CategoryFormEvent, CategoryState> {
  final CategoriesDao _categoriesDao;

  CategoryFormBloc(this._categoriesDao);

  @override
  CategoryState get initialState => CategoryFormState.initial();

  CategoryFormState get currentState => state as CategoryFormState;

  @override
  Stream<CategoryState> mapEventToState(
    CategoryFormEvent event,
  ) async* {
    if (event is AddCategory || event is FormClosed) {
      yield CategoryFormState.initial();
    }

    if (event is EditCategory) {
      yield currentState.copyWith(
        id: event.category.id,
        name: event.category.name,
        isNameValid: true,
        type: event.category.isAnIncome
            ? TransactionType.incomes
            : TransactionType.expenses,
        isTypeValid: true,
        icon: event.category.icon,
        isIconValid: true,
        iconColor: event.category.iconColor,
      );
    }

    if (event is NameChanged) {
      yield currentState.copyWith(
        name: event.name,
        isNameValid: isNameValid(event.name),
        isNameDirty: true,
      );
    }

    if (event is TypeChanged) {
      yield currentState.copyWith(
        type: event.selectedType,
        isTypeValid: true,
      );
    }

    if (event is IconChanged) {
      yield currentState.copyWith(
        icon: event.selectedIcon,
        isIconValid: true,
      );
    }

    if (event is IconColorChanged) {
      yield currentState.copyWith(iconColor: event.iconColor);
    }

    if (event is FormSubmitted) {
      yield* _saveCategory(currentState.buildCategoryItem());
    }

    if (event is DeleteCategory) {
      yield* _deleteCategory(currentState.buildCategoryItem());
    }
  }

  bool isNameValid(String name) => !name.isNullOrEmpty(
        minLength: 1,
        maxLength: 255,
      );

  Stream<CategoryState> _saveCategory(CategoryItem category) async* {
    try {
      final savedCategory = await _categoriesDao.saveCategory(category);
      yield CategorySavedState(savedCategory);
    } catch (e) {
      yield currentState.copyWith(errorOccurred: true);
    }
  }

  Stream<CategoryState> _deleteCategory(CategoryItem category) async* {
    try {
      await _categoriesDao.deleteCategory(category.id);
      yield CategoryDeletedState(category);
    } catch (e) {
      yield currentState.copyWith(errorOccurred: true);
    }
  }
}
