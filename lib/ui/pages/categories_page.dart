import 'package:flutter/material.dart';
import 'package:flutter_flexible_toast/flutter_flexible_toast.dart';
import 'package:provider/provider.dart';

import '../../generated/i18n.dart';
import '../../models/category_item.dart';
import '../../models/current_selected_category.dart';
import '../pages/categories_list_page.dart';

class CategoriesPage extends StatefulWidget {
  final bool isInSelectionMode;
  final CategoryItem selectedCategory;

  const CategoriesPage({
    this.isInSelectionMode = false,
    this.selectedCategory,
  });

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(
      initialIndex: 0,
      length: 2,
      vsync: this,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final i18n = I18n.of(context);
    final tabs = _buildTabs(context);
    final tabBar = TabBar(
      indicatorColor: theme.primaryColor,
      labelColor:
          theme.brightness == Brightness.dark ? Colors.white : Colors.black,
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
          IconButton(
            icon: Icon(Icons.done),
            onPressed: _onDone,
          ),
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
    final i18n = I18n.of(context);
    return [
      Tab(
        icon: Icon(
          Icons.more,
        ),
        text: i18n.incomes,
      ),
      Tab(
        icon: Icon(
          Icons.pages,
        ),
        text: i18n.expenses,
      ),
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

    final i18n = I18n.of(context);

    FlutterFlexibleToast.showToast(
      message: i18n.mustSelectCategory,
      toastLength: Toast.LENGTH_SHORT,
      toastGravity: ToastGravity.BOTTOM,
      icon: ICON.INFO,
      radius: 50,
      textColor: Colors.white,
      backgroundColor: Colors.blue,
      timeInSeconds: 2,
    );
  }
}
