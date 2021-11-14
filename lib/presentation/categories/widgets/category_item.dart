import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/models/models.dart' as models;
import 'package:my_expenses/presentation/category/add_edit_category_page.dart';
import 'package:provider/provider.dart';

class CategoryItem extends StatelessWidget {
  final bool isInSelectionMode;
  final models.CategoryItem category;

  const CategoryItem({
    required this.category,
    this.isInSelectionMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isAnotherItemSelected = false;

    if (isInSelectionMode) {
      final selectedCatProvider = Provider.of<models.CurrentSelectedCategory>(context, listen: false);
      isAnotherItemSelected = selectedCatProvider.currentSelectedItem != null && selectedCatProvider.currentSelectedItem!.id != category.id;
    }

    final icon = IconTheme(
      data: IconThemeData(color: category.iconColor),
      child: Icon(category.icon),
    );
    return Container(
      decoration: isInSelectionMode && !isAnotherItemSelected && category.isSelected ? BoxDecoration(color: theme.primaryColorLight) : null,
      child: ListTile(
        leading: icon,
        title: Text(category.name),
        onTap: () => _onItemClick(context),
      ),
    );
  }

  void _onItemClick(BuildContext context) {
    if (isInSelectionMode) {
      _handleItemClickOnSelectionMode(context);
    } else {
      _handleItemClick(context);
    }
  }

  void _handleItemClickOnSelectionMode(BuildContext context) {
    final selectedCatProvider = Provider.of<models.CurrentSelectedCategory>(context, listen: false);
    selectedCatProvider.currentSelectedItem = category;

    if (category.isAnIncome) {
      context.read<IncomesCategoriesBloc>().add(CategoriesListEvent.categoryWasSelected(wasSelected: true, selectedCategory: category));
      context.read<ExpensesCategoriesBloc>().add(const CategoriesListEvent.unSelectAll());
    } else {
      context.read<ExpensesCategoriesBloc>().add(CategoriesListEvent.categoryWasSelected(wasSelected: true, selectedCategory: category));
      context.read<IncomesCategoriesBloc>().add(const CategoriesListEvent.unSelectAll());
    }
  }

  Future _handleItemClick(BuildContext context) async {
    final route = MaterialPageRoute(builder: (ctx) => AddEditCategoryPage());

    context.read<CategoryFormBloc>().add(CategoryFormEvent.editCategory(category: category));
    await Navigator.of(context).push(route);
    await route.completed;
    context.read<CategoryFormBloc>().add(const CategoryFormEvent.formClosed());
  }
}
