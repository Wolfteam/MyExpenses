import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/categories/categories_page.dart';
import 'package:my_expenses/presentation/search/widgets/search_amount_filter_bottom_sheet_dialog.dart';
import 'package:my_expenses/presentation/search/widgets/search_date_filter_bottom_sheet_dialog.dart';
import 'package:my_expenses/presentation/shared/sort_direction_popupmenu_filter.dart';
import 'package:my_expenses/presentation/shared/styles.dart';
import 'package:my_expenses/presentation/shared/transaction_popupmenu_filter.dart';
import 'package:my_expenses/presentation/shared/transaction_popupmenu_type_filter.dart';
import 'package:provider/provider.dart';

class SearchFilterBar extends StatelessWidget {
  final double? currentAmountFilter;
  final CategoryItem? category;
  final TransactionFilterType transactionFilterType;
  final SortDirectionType sortDirectionType;
  final TransactionType? transactionType;

  const SearchFilterBar({
    super.key,
    this.currentAmountFilter,
    this.category,
    required this.transactionFilterType,
    required this.sortDirectionType,
    this.transactionType,
  });

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    return OverflowBar(
      alignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: const Icon(Icons.date_range),
          onPressed: () => _showDateFilterBottomSheet(context),
          tooltip: i18n.transactionDate,
          splashRadius: Styles.iconButtonSplashRadius,
        ),
        IconButton(
          icon: const Icon(Icons.attach_money),
          onPressed: () => _showAmountFilterBottomSheet(currentAmountFilter, context),
          tooltip: i18n.amount,
          splashRadius: Styles.iconButtonSplashRadius,
        ),
        IconButton(
          icon: const Icon(Icons.category),
          onPressed: () => _showCategoriesPage(category, context),
          tooltip: i18n.category,
          splashRadius: Styles.iconButtonSplashRadius,
        ),
        TransactionPopupMenuFilter(
          selectedValue: transactionFilterType,
          onSelected: (v) => _transactionFilterTypeChanged(v, context),
          exclude: const [TransactionFilterType.category],
        ),
        SortDirectionPopupMenuFilter(
          selectedSortDirection: sortDirectionType,
          onSelected: (v) => _sortDirectionChanged(v, context),
        ),
        TransactionPopupMenuTypeFilter(
          selectedValue: transactionType,
          onSelectedValue: (v) => _transactionTypeChanged(v == nothingSelected ? null : TransactionType.values[v], context),
          showNa: true,
        ),
      ],
    );
  }

  void _removeSearchFocus(BuildContext context) => FocusScope.of(context).unfocus();

  void _showDateFilterBottomSheet(BuildContext context) {
    _removeSearchFocus(context);
    final bloc = context.read<SearchBloc>();
    bloc.add(const SearchEvent.resetTempDates());
    showModalBottomSheet(
      shape: Styles.modalBottomSheetShape,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: bloc,
        child: SearchDateFilterBottomSheetDialog(),
      ),
    );
  }

  void _showAmountFilterBottomSheet(double? initialAmount, BuildContext context) {
    _removeSearchFocus(context);
    final bloc = context.read<SearchBloc>();
    bloc.add(const SearchEvent.resetTempDates());
    showModalBottomSheet(
      shape: Styles.modalBottomSheetShape,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: bloc,
        child: SearchAmountFilterBottomSheetDialog(initialAmount: initialAmount),
      ),
    );
  }

  Future<void> _showCategoriesPage(CategoryItem? category, BuildContext context) async {
    _removeSearchFocus(context);
    final selectedCatProvider = Provider.of<CurrentSelectedCategory>(context, listen: false);

    if (category != null && category.id > 0) {
      selectedCatProvider.currentSelectedItem = category;
    }

    final route = MaterialPageRoute<CategoryItem>(
      builder: (ctx) => CategoriesPage(isInSelectionMode: true, showDeselectButton: true, selectedCategory: category),
    );
    await Navigator.of(context).push(route).then((_) {
      if (context.mounted) {
        context.read<SearchBloc>().add(SearchEvent.categoryChanged(newValue: selectedCatProvider.currentSelectedItem));
      }
    });
  }

  void _transactionFilterTypeChanged(TransactionFilterType newValue, BuildContext context) {
    _removeSearchFocus(context);
    context.read<SearchBloc>().add(SearchEvent.transactionFilterChanged(newValue: newValue));
  }

  void _transactionTypeChanged(TransactionType? newValue, BuildContext context) {
    _removeSearchFocus(context);
    context.read<SearchBloc>().add(SearchEvent.transactionTypeChanged(newValue: newValue));
  }

  void _sortDirectionChanged(SortDirectionType newValue, BuildContext context) {
    _removeSearchFocus(context);
    context.read<SearchBloc>().add(SearchEvent.sortDirectionChanged(newValue: newValue));
  }
}
