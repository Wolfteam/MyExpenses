import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/models/models.dart' as models;
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/injection.dart';
import 'package:my_expenses/presentation/category/widgets/category_form.dart';
import 'package:my_expenses/presentation/category/widgets/category_header.dart';
import 'package:my_expenses/presentation/shared/dialogs/confirm_dialog.dart';
import 'package:my_expenses/presentation/shared/utils/bloc_utils.dart';
import 'package:my_expenses/presentation/shared/utils/toast_utils.dart';

class AddEditCategoryPage extends StatelessWidget {
  final models.CategoryItem? category;

  const AddEditCategoryPage({
    Key? key,
    this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) {
        final event = category == null ? const CategoryFormEvent.addCategory() : CategoryFormEvent.editCategory(category: category!);
        return Injection.categoryFormBloc..add(event);
      },
      child: const _Scaffold(),
    );
  }
}

class _Scaffold extends StatelessWidget {
  const _Scaffold({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    return BlocConsumer<CategoryFormBloc, CategoryState>(
      listener: (ctx, state) {
        state.maybeMap(
          loaded: (state) {
            if (state.errorOccurred) {
              ToastUtils.showWarningToast(ctx, i18n.unknownErrorOcurred);
            }

            if (state.categoryCantBeDeleted) {
              ToastUtils.showWarningToast(ctx, i18n.categoryCantBeDeleted);
            }
            if (state.saved || state.deleted) {
              _onCategoryAddedOrDeleted(context, state.deleted);
            }
          },
          orElse: () {},
        );
      },
      builder: (ctx, state) => Scaffold(
        appBar: state.maybeMap(
          loaded: (state) => _AppBar(
            name: state.name,
            isFormValid: ctx.read<CategoryFormBloc>().isFormValid(),
            isNewCategory: state.isNew,
          ),
          orElse: () => null,
        ),
        body: state.maybeMap(
          loaded: (state) => SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CategoryHeader(name: state.name, type: state.type, iconColor: state.iconColor, iconData: state.icon),
                if (state.isNew)
                  CategoryForm.create(type: state.type, iconData: state.icon, iconColor: state.iconColor)
                else
                  CategoryForm.edit(id: state.id, name: state.name, type: state.type, iconData: state.icon, iconColor: state.iconColor)
              ],
            ),
          ),
          orElse: () => null,
        ),
      ),
    );
  }

  void _onCategoryAddedOrDeleted(BuildContext context, bool deleted) {
    final s = S.of(context);
    final msg = deleted ? s.categoryWasSuccessfullyDeleted : s.categoryWasSuccessfullySaved;
    ToastUtils.showSucceedToast(context, msg);
    _notifyCategorySavedOrDeleted(context);
    Navigator.of(context).pop();
  }

  void _notifyCategorySavedOrDeleted(BuildContext context) {
    context.read<IncomesCategoriesBloc>().add(const CategoriesListEvent.getCategories(loadIncomes: true));
    context.read<ExpensesCategoriesBloc>().add(const CategoriesListEvent.getCategories(loadIncomes: false));
    BlocUtils.raiseCommonBlocEvents(context, reloadCategories: true, reloadCharts: true, reloadTransactions: true);
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  final String name;
  final bool isNewCategory;
  final bool isFormValid;

  const _AppBar({
    Key? key,
    required this.name,
    required this.isNewCategory,
    required this.isFormValid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    return AppBar(
      title: Text(
        isNewCategory ? i18n.addCategory : i18n.editCategory,
      ),
      leading: const BackButton(),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.save),
          onPressed: isFormValid ? () => _saveCategory(context) : null,
        ),
        if (!isNewCategory)
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmationDialog(context, name),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void _saveCategory(BuildContext context) => context.read<CategoryFormBloc>().add(const CategoryFormEvent.formSubmitted());

  Future<void> _showDeleteConfirmationDialog(BuildContext context, String categoryName) {
    final i18n = S.of(context);

    return showDialog(
      context: context,
      builder: (ctx) => ConfirmDialog(
        title: i18n.deleteX(categoryName),
        content: i18n.confirmDeleteCategory,
        onOk: () => context.read<CategoryFormBloc>().add(const CategoryFormEvent.deleteCategory()),
        okText: i18n.yes,
      ),
    );
  }
}
