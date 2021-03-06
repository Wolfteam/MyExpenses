import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../../bloc/categories_list/categories_list_bloc.dart';
import '../../../bloc/category_form/category_form_bloc.dart';
import '../../../models/category_item.dart' as models;
import '../../../models/current_selected_category.dart';
import '../../../ui/pages/add_edit_category_page.dart';

class CategoryItem extends StatelessWidget {
  final bool isInSelectionMode;
  final models.CategoryItem category;

  const CategoryItem({
    @required this.category,
    this.isInSelectionMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isAnotherItemSelected = false;

    if (isInSelectionMode) {
      final selectedCatProvider =
          Provider.of<CurrentSelectedCategory>(context, listen: false);
      isAnotherItemSelected = selectedCatProvider.currentSelectedItem != null &&
          selectedCatProvider.currentSelectedItem.id != category.id;
    }

    final icon = IconTheme(
      data: IconThemeData(color: category.iconColor),
      child: Icon(category.icon),
    );
    return Container(
      decoration:
          isInSelectionMode && !isAnotherItemSelected && category.isSeleted
              ? BoxDecoration(color: theme.primaryColorLight)
              : null,
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
    final selectedCatProvider =
        Provider.of<CurrentSelectedCategory>(context, listen: false);
    selectedCatProvider.currentSelectedItem = category;

    if (category.isAnIncome) {
      context.bloc<IncomesCategoriesBloc>().add(CategoryWasSelected(
            wasSelected: true,
            selectedCategory: category,
          ));
      context.bloc<ExpensesCategoriesBloc>().add(UnSelectAllCategories());
    } else {
      context.bloc<ExpensesCategoriesBloc>().add(CategoryWasSelected(
            wasSelected: true,
            selectedCategory: category,
          ));
      context.bloc<IncomesCategoriesBloc>().add(UnSelectAllCategories());
    }
  }

  Future _handleItemClick(BuildContext context) async {
    final route = MaterialPageRoute(
      builder: (ctx) => AddEditCategoryPage(category),
    );

    context.bloc<CategoryFormBloc>().add(EditCategory(category));
    await Navigator.of(context).push(route);
    context.bloc<CategoryFormBloc>().add(FormClosed());
  }
}
