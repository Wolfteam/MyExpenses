import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/models/current_selected_category.dart';
import 'package:provider/provider.dart';

import '../../bloc/bloc.dart';
import '../../models/category_item.dart' as models;

class CategoryItem extends StatelessWidget {
  final bool isInSelectionMode;
  final models.CategoryItem category;

  const CategoryItem({
    @required this.category,
    this.isInSelectionMode = false,
  });

  @override
  Widget build(BuildContext context) {
    bool isAnotherItemSelected = false;

    if (isInSelectionMode) {
      final selectedCatProvider = Provider.of<CurrentSelectedCategory>(context, listen: false);
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
              ? BoxDecoration(color: Colors.red)
              : null,
      child: ListTile(
        leading: icon,
        title: Text(category.name),
        onTap: () {
          if (isInSelectionMode) _handleItemClickOnSelectionMode(context);
        },
      ),
    );
  }

  void _handleItemClickOnSelectionMode(BuildContext context) {
    final selectedCatProvider = Provider.of<CurrentSelectedCategory>(context, listen: false);
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
}
