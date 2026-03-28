import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/categories/categories_page.dart';
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
      bottomNavigationBar: BlocListener<DrawerBloc, DrawerState>(
        listener: (ctx, state) {
          if (state.userSignedOut) {
            BlocUtils.raiseAllCommonBlocEvents(context);
          }
        },
        child: BottomNavigationBar(
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

  void _changeCurrentTab(int index) {
    if (widget.tabController.index == index && _index == index) {
      return;
    }
    widget.tabController.index = index;
    setState(() {
      _index = index;
    });
  }

  Future<void> _gotoAddTransactionPage(BuildContext context) async {
    final route = AddEditTransactionPage.addRoute(context);
    await Navigator.of(context).push(route);
    await route.completed;
  }
}
