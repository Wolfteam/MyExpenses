import 'package:flutter/material.dart';

import '../pages/categories_page.dart';
import '../pages/charts_page.dart';
import '../pages/settings_page.dart';
import '../pages/transactions_page.dart';
import '../pages/add_edit_transasctiton_page.dart';
import '../widgets/app_drawer.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _currentPageIndex = 0;
  var _pages = <Widget>[
    TransactionsPage(),
    ChartsPage(),
    CategoriesPage(),
    SettingsPage(),
  ];
  TabController _tabController;

  @override
  void initState() {
    _tabController =
        TabController(initialIndex: 0, length: _pages.length, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("My expenses"),
      ),
      drawer: AppDrawer(),
      body: TabBarView(
        children: _pages,
        controller: _tabController,
        physics: NeverScrollableScrollPhysics(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: colorScheme.secondary,
        mini: false,
        heroTag: "CreateTransactionFab",
        onPressed: () {
          var route = MaterialPageRoute(builder: (ctx) => AddEditTransactionPage());
          Navigator.of(context).push(route);
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentPageIndex,
        selectedItemColor: colorScheme.onPrimary,
        unselectedItemColor: colorScheme.onPrimary.withOpacity(0.5),
        backgroundColor: colorScheme.primary,
        onTap: (index) {
          setState(() {
            _currentPageIndex = index;
            _tabController.animateTo(_currentPageIndex);
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            title: Text("Transactions"),
            icon: Icon(Icons.account_balance),
          ),
          BottomNavigationBarItem(
            title: Text("Charts"),
            icon: Icon(Icons.pie_chart),
          ),
          BottomNavigationBarItem(
            title: Text("Categories"),
            icon: Icon(Icons.category),
          ),
          BottomNavigationBarItem(
            title: Text("Settings"),
            icon: Icon(Icons.settings),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
