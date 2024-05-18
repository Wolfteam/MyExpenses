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
    super.key,
    required this.loadIncomes,
    this.isInSelectionMode = false,
    this.selectedCategory,
  });

  @override
  _CategoriesListPageState createState() => _CategoriesListPageState();
}

class _CategoriesListPageState extends State<CategoriesListPage> with AutomaticKeepAliveClientMixin<CategoriesListPage> {
  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final event = CategoriesListEvent.getCategories(loadIncomes: widget.loadIncomes, selectedCategory: widget.selectedCategory);
    if (widget.loadIncomes) {
      context.read<IncomesCategoriesBloc>().add(event);
    } else {
      context.read<ExpensesCategoriesBloc>().add(event);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: widget.loadIncomes
          ? BlocBuilder<IncomesCategoriesBloc, CategoriesListState>(
              builder: (ctx, state) => state.maybeMap(
                loaded: (state) => _List(categories: state.categories, isInSelectionMode: widget.isInSelectionMode),
                orElse: () => const Center(child: CircularProgressIndicator()),
              ),
            )
          : BlocBuilder<ExpensesCategoriesBloc, CategoriesListState>(
              builder: (ctx, state) => state.maybeMap(
                loaded: (state) => _List(categories: state.categories, isInSelectionMode: widget.isInSelectionMode),
                orElse: () => const Center(child: CircularProgressIndicator()),
              ),
            ),
      floatingActionButton: !widget.isInSelectionMode
          ? FloatingActionButton(
              heroTag: widget.loadIncomes ? 'AddIncomesFab' : 'AddExpensesFab',
              onPressed: _gotoAddCategoryPage,
              mini: true,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Future _gotoAddCategoryPage() async {
    final route = MaterialPageRoute(builder: (ctx) => const AddEditCategoryPage());
    await Navigator.of(context).push(route);
    await route.completed;
  }
}

class _List extends StatelessWidget {
  final List<models.CategoryItem> categories;
  final bool isInSelectionMode;

  const _List({
    required this.categories,
    required this.isInSelectionMode,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: categories.length,
      //just to avoid problems on desktop
      controller: ScrollController(),
      itemBuilder: (ctx, index) => CategoryItem(
        category: categories[index],
        isInSelectionMode: isInSelectionMode,
      ),
    );
  }
}
