import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/drawer/drawer_bloc.dart';
import '../../common/enums/app_drawer_item_type.dart';
import '../../generated/i18n.dart';
import '../pages/add_edit_transasctiton_page.dart';
import '../pages/categories_page.dart';
import '../pages/charts_page.dart';
import '../pages/settings_page.dart';
import '../pages/transactions_page.dart';
import '../widgets/drawer/app_drawer.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  final _pages = <Widget>[
    TransactionsPage(),
    ChartsPage(),
    const CategoriesPage(),
    SettingsPage(),
  ];
  TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: _pages.length, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).appName),
      ),
      drawer: AppDrawer(),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        heroTag: 'CreateTransactionFab',
        onPressed: _gotoAddTransactionPage,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BlocConsumer<DrawerBloc, DrawerState>(
        listener: (ctx, state) {
          final index = _getSelectedIndex(state.selectedPage);
          _tabController.animateTo(index);
        },
        builder: (ctx, state) {
          final index = _getSelectedIndex(state.selectedPage);
          return BottomNavigationBar(
            showUnselectedLabels: true,
            selectedItemColor: Theme.of(context).primaryColor,
            type: BottomNavigationBarType.fixed,
            currentIndex: index,
            onTap: _changeCurrentTab,
            items: _buildBottomNavBars(),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<BottomNavigationBarItem> _buildBottomNavBars() {
    final i18n = I18n.of(context);
    return [
      BottomNavigationBarItem(
        title: Text(i18n.transactions),
        icon: const Icon(Icons.account_balance),
      ),
      BottomNavigationBarItem(
        title: Text(i18n.charts),
        icon: const Icon(Icons.pie_chart),
      ),
      BottomNavigationBarItem(
        title: Text(i18n.categories),
        icon: const Icon(Icons.category),
      ),
      BottomNavigationBarItem(
        title: Text(i18n.config),
        icon: const Icon(Icons.settings),
      ),
    ];
  }

  int _getSelectedIndex(AppDrawerItemType item) {
    int index;
    switch (item) {
      case AppDrawerItemType.transactions:
        index = 0;
        break;
      case AppDrawerItemType.charts:
        index = 1;
        break;
      case AppDrawerItemType.categories:
        index = 2;
        break;
      case AppDrawerItemType.settings:
        index = 3;
        break;
      default:
        throw Exception(
          'The selected drawer item = $item is not valid in the bottom nav bar items',
        );
    }

    return index;
  }

  AppDrawerItemType _getSelectedDrawerItem(int index) {
    if (index == 0) return AppDrawerItemType.transactions;
    if (index == 1) return AppDrawerItemType.charts;
    if (index == 2) return AppDrawerItemType.categories;
    if (index == 3) return AppDrawerItemType.settings;

    throw Exception(
      'The provided inxed = $index is not valid in the bottom nav bar items',
    );
  }

  void _changeCurrentTab(int index) {
    final item = _getSelectedDrawerItem(index);
    context.bloc<DrawerBloc>().add(DrawerItemSelectionChanged(item));
  }

  Future<void> _gotoAddTransactionPage() async {
    final route = MaterialPageRoute(
      builder: (ctx) => const AddEditTransactionPage(),
    );
    await Navigator.of(context).push(route);
  }
}
