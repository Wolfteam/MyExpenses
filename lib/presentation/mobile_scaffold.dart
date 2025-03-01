import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/categories/categories_page.dart';
import 'package:my_expenses/presentation/drawer/app_drawer.dart';
import 'package:my_expenses/presentation/search/search_page.dart';
import 'package:my_expenses/presentation/settings/settings_page.dart';
import 'package:my_expenses/presentation/shared/utils/bloc_utils.dart';
import 'package:my_expenses/presentation/transaction/add_edit_transaction_page.dart';
import 'package:my_expenses/presentation/transactions/transactions_page.dart';

class MobileScaffold extends StatefulWidget {
  final int defaultIndex;
  final TabController tabController;

  const MobileScaffold({
    super.key,
    required this.defaultIndex,
    required this.tabController,
  });

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
      drawer: AppDrawer(),
      body: SafeArea(
        child: TabBarView(
          controller: widget.tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            TransactionsPage(),
            const CategoriesPage(),
            SearchPage(),
            SettingsPage(),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        heroTag: 'CreateTransactionFab',
        onPressed: () => _gotoAddTransactionPage(context),
        tooltip: i18n.addTransaction,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BlocConsumer<DrawerBloc, DrawerState>(
        listener: (ctx, state) => _onDrawerStateChanged(state),
        builder: (ctx, state) => BottomNavigationBar(
          showUnselectedLabels: true,
          landscapeLayout: BottomNavigationBarLandscapeLayout.linear,
          type: BottomNavigationBarType.fixed,
          currentIndex: _index,
          onTap: _changeCurrentTab,
          items: [
            BottomNavigationBarItem(
              label: i18n.transactions,
              icon: const Icon(Icons.account_balance),
              tooltip: i18n.transactions,
            ),
            BottomNavigationBarItem(
              label: i18n.categories,
              icon: const Icon(Icons.category),
              tooltip: i18n.categories,
            ),
            BottomNavigationBarItem(
              label: i18n.search,
              icon: const Icon(Icons.search),
              tooltip: i18n.search,
            ),
            BottomNavigationBarItem(
              label: i18n.config,
              icon: const Icon(Icons.settings),
              tooltip: i18n.config,
            ),
          ],
        ),
      ),
    );
  }

  int _getSelectedIndex(AppDrawerItemType item) {
    int index;
    switch (item) {
      case AppDrawerItemType.transactions:
        index = 0;
      case AppDrawerItemType.categories:
        index = 1;
      case AppDrawerItemType.search:
        index = 2;
      case AppDrawerItemType.settings:
        index = 3;
      default:
        throw Exception('The selected drawer item = $item is not valid in the bottom nav bar items');
    }

    return index;
  }

  void _onDrawerStateChanged(DrawerState state) {
    if (state.userSignedOut) {
      BlocUtils.raiseAllCommonBlocEvents(context);
    }

    _onPageSelected(state.selectedPage);
  }

  void _onPageSelected(AppDrawerItemType page) {
    final index = _getSelectedIndex(page);
    widget.tabController.animateTo(index);
    _changeCurrentTab(index);
  }

  void _changeCurrentTab(int index) {
    final item = _getSelectedDrawerItem(index);
    if (widget.tabController.index == index && _index == index) {
      return;
    }
    widget.tabController.index = index;
    context.read<DrawerBloc>().add(DrawerEvent.selectedItemChanged(selectedPage: item));
    setState(() {
      _index = index;
    });
  }

  AppDrawerItemType _getSelectedDrawerItem(int index) {
    if (index == 0) return AppDrawerItemType.transactions;
    if (index == 1) return AppDrawerItemType.categories;
    if (index == 2) return AppDrawerItemType.search;
    if (index == 3) return AppDrawerItemType.settings;

    throw Exception('The provided index = $index is not valid in the bottom nav bar items');
  }

  Future<void> _gotoAddTransactionPage(BuildContext context) async {
    final route = AddEditTransactionPage.addRoute(context);
    await Navigator.of(context).push(route);
    await route.completed;
  }
}
