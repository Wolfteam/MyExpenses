import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/models/models.dart' as models;
import 'package:my_expenses/presentation/categories/widgets/category_item.dart';
import 'package:my_expenses/presentation/category/add_edit_category_page.dart';

class CategoriesListPage extends StatefulWidget {
  final bool loadIncomes;
  final bool isInSelectionMode;
  final models.CategoryItem? selectedCategory;

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
        itemBuilder: (ctx, index) => CategoryItem(
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
    await route.completed;

    if (mounted) {
      context.read<CategoryFormBloc>().add(const CategoryFormEvent.formClosed());
    }
  }
}
