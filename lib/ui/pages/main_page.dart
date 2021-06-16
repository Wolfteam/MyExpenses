import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/bloc/main_tab/main_tab_bloc.dart';
import 'package:my_expenses/bloc/transaction_form/transaction_form_bloc.dart';
import 'package:my_expenses/common/enums/notification_type.dart';
import 'package:my_expenses/common/extensions/string_extensions.dart';
import 'package:my_expenses/common/utils/i18n_utils.dart';
import 'package:my_expenses/common/utils/notification_utils.dart';
import 'package:my_expenses/common/utils/toast_utils.dart';
import 'package:my_expenses/daos/transactions_dao.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/injection.dart';
import 'package:my_expenses/models/app_notification.dart';
import 'package:my_expenses/services/logging_service.dart';
import 'package:my_expenses/services/settings_service.dart';
import 'package:my_expenses/ui/pages/add_edit_transasctiton_page.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../bloc/drawer/drawer_bloc.dart';
import '../../common/enums/app_drawer_item_type.dart';
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
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: _pages.length, vsync: this);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    context.read<MainTabBloc>().add(const MainTabEvent.init());
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MainTabBloc, MainTabState>(
      listener: (ctx, state) async {
        await setupNotifications(
          onIosReceiveLocalNotification: _onDidReceiveLocalNotification,
          onSelectNotification: (payload) => _onSelectNotification(payload),
        );
      },
      child: Scaffold(
        appBar: AppBar(title: Text(S.of(context).appName)),
        drawer: AppDrawer(),
        body: SafeArea(
          child: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: _pages,
          ),
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
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<BottomNavigationBarItem> _buildBottomNavBars() {
    final i18n = S.of(context);
    return [
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

    throw Exception('The provided index = $index is not valid in the bottom nav bar items');
  }

  void _changeCurrentTab(int index) {
    final item = _getSelectedDrawerItem(index);
    context.read<DrawerBloc>().add(DrawerEvent.selectedItemChanged(selectedPage: item));
  }

  Future<void> _gotoAddTransactionPage() async {
    final route = AddEditTransactionPage.addRoute(context);
    await Navigator.of(context).push(route);
    await route.completed;
  }

  Future<dynamic> _onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) async {
    final i18n = S.of(context);
    return showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title!),
        content: Text(body!),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text(i18n.ok),
          )
        ],
      ),
    );
  }

  Future<void> _onSelectNotification(String? json) async {
    if (json.isNullEmptyOrWhitespace) {
      return;
    }

    final settingsService = getIt<SettingsService>();
    final logger = getIt<LoggingService>();
//TODO: IF YOU OPEN THE NOTIFICATION WHILE THE APP IS CLOSED, NOTHING HAPPENS
    try {
      WidgetsFlutterBinding.ensureInitialized();
      final notification = AppNotification.fromJson(jsonDecode(json!) as Map<String, dynamic>);

      final i18n = await getI18n(settingsService.language);
      switch (notification.type) {
        case NotificationType.openCsv:
        case NotificationType.openPdf:
          //open_file crashes while asking for permissions...
          //that's why whe ask for them before opening the file
          final granted = await Permission.storage.isGranted;
          if (!granted) {
            final result = await Permission.storage.request();
            if (!result.isGranted) {
              ToastUtils.showWarningToast(context, i18n.openFilePermissionRequestFailedMsg);
              return;
            }
          }
          final file = File(notification.payload!);
          if (await file.exists()) {
            final openResult = await OpenFile.open(file.path);
            switch (openResult.type) {
              case ResultType.done:
                break;
              case ResultType.fileNotFound:
                ToastUtils.showInfoToast(context, i18n.fileNotFound(notification.payload!));
                break;
              case ResultType.noAppToOpen:
                ToastUtils.showInfoToast(context, i18n.noAppToOpenFile);
                break;
              case ResultType.permissionDenied:
                ToastUtils.showWarningToast(context, i18n.openFilePermissionRequestFailedMsg);
                break;
              case ResultType.error:
                ToastUtils.showErrorToast(context, i18n.unknownErrorOcurred);
                break;
            }
          }
          break;
        case NotificationType.openTransactionDetails:
          final transDao = getIt<TransactionsDao>();
          final transaction = await transDao.getTransaction(int.parse(notification.payload!));
          final route = AddEditTransactionPage.editRoute(transaction, context);
          await Navigator.push(context, route);
          await route.completed;
          context.read<TransactionFormBloc>().add(const TransactionFormEvent.close());
          break;
        case NotificationType.msg:
          break;
      }
    } catch (e, s) {
      logger.error(runtimeType, 'Unknown error', e, s);
    }
  }
}
