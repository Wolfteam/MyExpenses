import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/categories_list/categories_list_bloc.dart';
import '../../bloc/category_form/category_form_bloc.dart';
import '../../common/utils/bloc_utils.dart';
import '../../models/category_item.dart';
import '../widgets/categories/category_item.dart' as cat_item;
import 'add_edit_category_page.dart';

class CategoriesListPage extends StatefulWidget {
  final bool loadIncomes;
  final bool isInSelectionMode;
  final CategoryItem selectedCategory;

  const CategoriesListPage({
    Key key,
    @required this.loadIncomes,
    this.isInSelectionMode = false,
    this.selectedCategory,
  }) : super(key: key);

  @override
  _CategoriesListPageState createState() => _CategoriesListPageState();
}

class _CategoriesListPageState extends State<CategoriesListPage>
    with AutomaticKeepAliveClientMixin<CategoriesListPage> {
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
    if (state is CategoriesLoadedState) {
      return ListView.builder(
        itemCount: state.categories.length,
        itemBuilder: (ctx, index) => cat_item.CategoryItem(
          category: state.categories[index],
          isInSelectionMode: widget.isInSelectionMode,
        ),
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  void _loadCategories() {
    final event = GetCategories(
      loadIncomes: widget.loadIncomes,
      selectedCategory: widget.selectedCategory,
    );
    if (widget.loadIncomes) {
      context.bloc<IncomesCategoriesBloc>().add(event);
    } else {
      context.bloc<ExpensesCategoriesBloc>().add(event);
    }
  }

  Future _gotoAddCategoryPage() async {
    final route = MaterialPageRoute(
      builder: (ctx) => const AddEditCategoryPage(null),
    );

    context.bloc<CategoryFormBloc>().add(AddCategory());
    await Navigator.of(context).push(route);
    context.bloc<CategoryFormBloc>().add(FormClosed());
    BlocUtils.raiseCommonBlocEvents(
      context,
      reloadCategories: true,
      reloadCharts: true,
      reloadTransactions: true,
    );
  }
}
