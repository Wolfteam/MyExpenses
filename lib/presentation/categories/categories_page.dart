import 'package:flutter/material.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/categories/categories_list_page.dart';
import 'package:my_expenses/presentation/shared/utils/toast_utils.dart';
import 'package:provider/provider.dart';

class CategoriesPage extends StatefulWidget {
  final bool isInSelectionMode;
  final bool showDeselectButton;
  final CategoryItem? selectedCategory;

  const CategoriesPage({
    this.isInSelectionMode = false,
    this.showDeselectButton = false,
    this.selectedCategory,
  });

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    final tabBar = TabBar(
      controller: _tabController,
      tabs: [
        Tab(text: i18n.incomes),
        Tab(text: i18n.expenses),
      ],
    );

    if (!widget.isInSelectionMode) {
      return Scaffold(
        appBar: tabBar,
        body: _TabBarView(
          tabController: _tabController,
          isInSelectionMode: widget.isInSelectionMode,
          selectedCategory: widget.selectedCategory,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(icon: const Icon(Icons.done), onPressed: _onDone),
          if (widget.showDeselectButton)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _deSelect,
            ),
        ],
        title: Text(i18n.selectCategory),
        bottom: tabBar,
      ),
      body: _TabBarView(
        tabController: _tabController,
        isInSelectionMode: widget.isInSelectionMode,
        selectedCategory: widget.selectedCategory,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onDone() {
    final selectedCatProvider = Provider.of<CurrentSelectedCategory>(
      context,
      listen: false,
    );

    if (selectedCatProvider.currentSelectedItem != null) {
      Navigator.of(context).pop(selectedCatProvider.currentSelectedItem);
      return;
    }

    final i18n = S.of(context);

    ToastUtils.showInfoToast(context, i18n.mustSelectCategory);
  }

  void _deSelect() {
    final selectedCatProvider = Provider.of<CurrentSelectedCategory>(
      context,
      listen: false,
    );

    selectedCatProvider.currentSelectedItem = null;
    Navigator.of(context).pop(selectedCatProvider.currentSelectedItem);
  }
}

class _TabBarView extends StatelessWidget {
  final bool isInSelectionMode;
  final CategoryItem? selectedCategory;
  final TabController tabController;

  const _TabBarView({
    required this.tabController,
    required this.isInSelectionMode,
    required this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: tabController,
      children: [
        CategoriesListPage(
          loadIncomes: true,
          isInSelectionMode: isInSelectionMode,
          selectedCategory: selectedCategory,
        ),
        CategoriesListPage(
          loadIncomes: false,
          isInSelectionMode: isInSelectionMode,
          selectedCategory: selectedCategory,
        ),
      ],
    );
  }
}
