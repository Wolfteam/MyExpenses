import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/categories_list/categories_list_bloc.dart';
import '../../bloc/category_form/category_form_bloc.dart';
import '../../models/category_item.dart';
import '../widgets/categories/category_item.dart' as cat_item;
import 'add_edit_category_page.dart';

class CategoriesListPage extends StatefulWidget {
  final bool loadIncomes;
  final bool isInSelectionMode;
  final CategoryItem? selectedCategory;

  const CategoriesListPage({
    Key? key,
    required this.loadIncomes,
    this.isInSelectionMode = false,
    this.selectedCategory,
  }) : super(key: key);

  @override
  _CategoriesListPageState createState() => _CategoriesListPageState();
}

class _CategoriesListPageState extends State<CategoriesListPage> with AutomaticKeepAliveClientMixin<CategoriesListPage> {
  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: widget.loadIncomes
          ? BlocBuilder<IncomesCategoriesBloc, CategoriesListState>(
              builder: (ctx, state) => _buildPage(state),
            )
          : BlocBuilder<ExpensesCategoriesBloc, CategoriesListState>(
              builder: (ctx, state) => _buildPage(state),
            ),
      floatingActionButton: !widget.isInSelectionMode
          ? FloatingActionButton(
              heroTag: widget.loadIncomes ? 'AddIncomesFab' : 'AddExpensesFab',
              onPressed: _gotoAddCategoryPage,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildPage(CategoriesListState state) {
    return state.maybeMap(
      loaded: (state) => ListView.builder(
        itemCount: state.categories.length,
        itemBuilder: (ctx, index) => cat_item.CategoryItem(
          category: state.categories[index],
          isInSelectionMode: widget.isInSelectionMode,
        ),
      ),
      orElse: () => const Center(child: CircularProgressIndicator()),
    );
  }

  void _loadCategories() {
    final event = CategoriesListEvent.getCategories(loadIncomes: widget.loadIncomes, selectedCategory: widget.selectedCategory);
    if (widget.loadIncomes) {
      context.read<IncomesCategoriesBloc>().add(event);
    } else {
      context.read<ExpensesCategoriesBloc>().add(event);
    }
  }

  Future _gotoAddCategoryPage() async {
    final route = MaterialPageRoute(builder: (ctx) => AddEditCategoryPage());
    context.read<CategoryFormBloc>().add(const CategoryFormEvent.addCategory());
    await Navigator.of(context).push(route);
    context.read<CategoryFormBloc>().add(const CategoryFormEvent.formClosed());
  }
}
