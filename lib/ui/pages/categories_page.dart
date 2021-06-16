import 'package:flutter/material.dart';
import 'package:my_expenses/common/utils/toast_utils.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:provider/provider.dart';

import '../../models/category_item.dart';
import '../../models/current_selected_category.dart';
import '../pages/categories_list_page.dart';

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
    final theme = Theme.of(context);
    final i18n = S.of(context);
    final tabs = _buildTabs(context);
    final tabBar = TabBar(
      indicatorColor: theme.primaryColor,
      labelColor: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
      // unselectedLabelColor: theme.unselectedWidgetColor,
      controller: _tabController,
      tabs: tabs,
    );

    if (!widget.isInSelectionMode) {
      return Scaffold(
        appBar: tabBar,
        body: TabBarView(
          controller: _tabController,
          children: _buildCategoriesListPages(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(icon: const Icon(Icons.done), onPressed: _onDone),
          if (widget.showDeselectButton) IconButton(icon: const Icon(Icons.clear_all), onPressed: _deSelect),
        ],
        title: Text(i18n.selectCategory),
        bottom: tabBar,
      ),
      body: TabBarView(
        controller: _tabController,
        children: _buildCategoriesListPages(),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Tab> _buildTabs(BuildContext context) {
    final i18n = S.of(context);
    return [
      Tab(icon: const Icon(Icons.more), text: i18n.incomes),
      Tab(icon: const Icon(Icons.pages), text: i18n.expenses),
    ];
  }

  List<CategoriesListPage> _buildCategoriesListPages() {
    final incomes = CategoriesListPage(
      loadIncomes: true,
      isInSelectionMode: widget.isInSelectionMode,
      selectedCategory: widget.selectedCategory,
    );
    final expenses = CategoriesListPage(
      loadIncomes: false,
      isInSelectionMode: widget.isInSelectionMode,
      selectedCategory: widget.selectedCategory,
    );

    return [incomes, expenses];
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
