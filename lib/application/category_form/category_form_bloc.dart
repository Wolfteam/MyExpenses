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

  CategoryStateLoadedState get currentState => state as CategoryStateLoadedState;

  static int maxNameLength = 30;

  CategoryFormBloc(this._logger, this._categoriesDao, this._usersDao) : super(const CategoryState.loading()) {
    on<CategoryFormEventAddCategory>((event, emit) {
      final s = CategoryState.loaded(
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
      );
      emit(s);
    });

    on<CategoryFormEventEditCategory>((event, emit) {
      final s = CategoryState.loaded(
        id: event.category.id,
        name: event.category.name,
        isNameValid: true,
        type: event.category.isAnIncome ? TransactionType.incomes : TransactionType.expenses,
        isTypeValid: true,
        icon: event.category.icon!,
        isIconValid: true,
        iconColor: event.category.iconColor!,
        isFormValid: true,
        isNew: false,
        isNameDirty: false,
      );
      emit(s);
    });

    on<CategoryFormEventNameChanged>((event, emit) {
      final s = switch (state) {
        CategoryStateLoadingState() => state,
        final CategoryStateLoadedState state => state.copyWith(
          name: event.name,
          isNameValid: isNameValid(event.name),
          isNameDirty: true,
        ),
      };
      emit(s);
    });

    on<CategoryFormEventTypeChanged>((event, emit) {
      final s = switch (state) {
        CategoryStateLoadingState() => state,
        final CategoryStateLoadedState state => state.copyWith(type: event.selectedType, isTypeValid: true),
      };
      emit(s);
    });

    on<CategoryFormEventIconChanged>((event, emit) {
      final s = switch (state) {
        CategoryStateLoadingState() => state,
        final CategoryStateLoadedState state => state.copyWith(icon: event.selectedIcon, isIconValid: true),
      };
      emit(s);
    });

    on<CategoryFormEventIconColorChanged>((event, emit) {
      final s = switch (state) {
        CategoryStateLoadingState() => state,
        final CategoryStateLoadedState state => state.copyWith(iconColor: event.iconColor),
      };
      emit(s);
    });

    on<CategoryFormEventDeleteCategory>(
      (event, emit) => _onSaveOrDelete(emit, () async {
        final s = await _deleteCategory();
        emit(s);
        if (state is CategoryStateLoadedState && currentState.categoryCantBeDeleted) {
          final s = currentState.copyWith.call(categoryCantBeDeleted: false);
          emit(s);
        }
      }),
    );

    on<CategoryFormEventFormSubmitted>(
      (event, emit) => _onSaveOrDelete(emit, () async {
        final s = await _saveCategory();
        emit(s);
      }),
    );
  }

  Future<void> _onSaveOrDelete(Emitter<CategoryState> emit, Future<void> Function() body) async {
    try {
      await body.call();
    } catch (e, s) {
      _logger.error(runtimeType, 'An unknown error occurred', e, s);
      if (state is CategoryStateLoadedState) {
        emit(currentState.copyWith.call(errorOccurred: true));
        emit(currentState.copyWith.call(errorOccurred: false, categoryCantBeDeleted: false));
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
