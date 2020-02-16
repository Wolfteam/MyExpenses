import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../pages/add_edit_transasctiton_page.dart';
import '../pages/categories_page.dart';
import '../pages/charts_page.dart';
import '../pages/settings_page.dart';
import '../pages/transactions_page.dart';
import '../widgets/app_drawer.dart';
import './../bloc/bloc.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _currentPageIndex = 0;
  final _pages = <Widget>[
    TransactionsPage(),
    ChartsPage(),
    const CategoriesPage(),
    SettingsPage(),
  ];
  TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(
      initialIndex: 0,
      length: _pages.length,
      vsync: this,
    );
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
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.secondary,
        mini: false,
        heroTag: "CreateTransactionFab",
        onPressed: () async {
          final route = MaterialPageRoute(
            builder: (ctx) => const AddEditTransactionPage(),
          );
          await Navigator.of(context).push(route);
          context.bloc<TransactionFormBloc>().add(FormClosed());
        },
        child: const Icon(Icons.add),
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
