import 'package:flutter/material.dart';
import '../pages/categories_list_page.dart';

class CategoriesPage extends StatefulWidget {
  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage>
    with SingleTickerProviderStateMixin {
  var _tabs = [
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
    return Scaffold(
      appBar: TabBar(
        indicatorColor: Colors.blueGrey,
        labelColor: Colors.red,
        unselectedLabelColor: Colors.grey,
        controller: _tabController,
        tabs: _tabs,
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map(
          (Tab t) {
            return CategoriesListPage();
          },
        ).toList(),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
