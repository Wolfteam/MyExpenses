import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/categories/categories_page.dart';
import 'package:my_expenses/presentation/charts/charts_page.dart';
import 'package:my_expenses/presentation/drawer/app_drawer.dart';
import 'package:my_expenses/presentation/settings/settings_page.dart';
import 'package:my_expenses/presentation/transaction/add_edit_transaction_page.dart';
import 'package:my_expenses/presentation/transactions/transactions_page.dart';

class MobileScaffold extends StatefulWidget {
  final int defaultIndex;
  final TabController tabController;

  const MobileScaffold({
    Key? key,
    required this.defaultIndex,
    required this.tabController,
  }) : super(key: key);

  @override
  State<MobileScaffold> createState() => _MobileScaffoldState();
}

class _MobileScaffoldState extends State<MobileScaffold> with SingleTickerProviderStateMixin {
  late int _index;

  @override
  void initState() {
    _index = widget.defaultIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).appName)),
      drawer: AppDrawer(),
      body: SafeArea(
        child: TabBarView(
          controller: widget.tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            TransactionsPage(),
            ChartsPage(),
            const CategoriesPage(),
            SettingsPage(),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        heroTag: 'CreateTransactionFab',
        onPressed: () => _gotoAddTransactionPage(context),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BlocConsumer<DrawerBloc, DrawerState>(
        listener: (ctx, state) => _onPageSelected(state.selectedPage),
        builder: (ctx, state) {
          return BottomNavigationBar(
            showUnselectedLabels: true,
            selectedItemColor: Theme.of(context).primaryColor,
            type: BottomNavigationBarType.fixed,
            currentIndex: _index,
            onTap: _changeCurrentTab,
            items: [
              BottomNavigationBarItem(
                label: i18n.transactions,
                icon: const Icon(Icons.account_balance),
              ),
              BottomNavigationBarItem(
                label: i18n.charts,
                icon: const Icon(Icons.pie_chart),
              ),
              BottomNavigationBarItem(
                label: i18n.categories,
                icon: const Icon(Icons.category),
              ),
              BottomNavigationBarItem(
                label: i18n.config,
                icon: const Icon(Icons.settings),
              ),
            ],
          );
        },
      ),
    );
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
        throw Exception('The selected drawer item = $item is not valid in the bottom nav bar items');
    }

    return index;
  }

  void _onPageSelected(AppDrawerItemType page) {
    final index = _getSelectedIndex(page);
    widget.tabController.animateTo(index);
    _changeCurrentTab(index);
  }

  void _changeCurrentTab(int index) {
    final item = _getSelectedDrawerItem(index);
    widget.tabController.index = index;
    context.read<DrawerBloc>().add(DrawerEvent.selectedItemChanged(selectedPage: item));
    setState(() {
      _index = index;
    });
  }

  AppDrawerItemType _getSelectedDrawerItem(int index) {
    if (index == 0) return AppDrawerItemType.transactions;
    if (index == 1) return AppDrawerItemType.charts;
    if (index == 2) return AppDrawerItemType.categories;
    if (index == 3) return AppDrawerItemType.settings;

    throw Exception('The provided index = $index is not valid in the bottom nav bar items');
  }

  Future<void> _gotoAddTransactionPage(BuildContext context) async {
    final route = AddEditTransactionPage.addRoute(context);
    await Navigator.of(context).push(route);
    await route.completed;
  }
}
