import 'package:flutter/material.dart';
import 'package:flutter_flexible_toast/flutter_flexible_toast.dart';
import 'package:my_expenses/models/category_item.dart';
import 'package:my_expenses/models/current_selected_category.dart';
import 'package:my_expenses/widgets/colored_tabbar.dart';
import 'package:provider/provider.dart';
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
  final _tabs = [
    Tab(
      icon: Icon(
        Icons.more,
      ),
      text: "Incomes",
    ),
    Tab(
      icon: Icon(
        Icons.pages,
      ),
      text: "Expenses",
    ),
  ];

  TabController _tabController;

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

  @override
  void initState() {
    _tabController = TabController(
      initialIndex: 0,
      length: _tabs.length,
      vsync: this,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final tabBar = TabBar(
      indicatorColor: Colors.blueGrey,
      labelColor: Colors.red,
      unselectedLabelColor: Colors.grey,
      controller: _tabController,
      tabs: _tabs,
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
        title: Text("Select a category"),
        bottom: ColoredTabBar(Colors.white, tabBar),
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

  void _onDone() {
    final selectedCatProvider =
        Provider.of<CurrentSelectedCategory>(context, listen: false);

    if (selectedCatProvider.currentSelectedItem != null) {
      Navigator.of(context).pop(selectedCatProvider.currentSelectedItem);
      return;
    }

    FlutterFlexibleToast.showToast(
      message: 'You must select a category',
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
