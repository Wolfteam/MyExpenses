import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/drawer/user_accounts_bottom_sheet_dialog.dart';
import 'package:my_expenses/presentation/estimates/estimate_bottom_sheet_dialog.dart';
import 'package:my_expenses/presentation/reports/reports_bottom_sheet_dialog.dart';
import 'package:my_expenses/presentation/search/search_page.dart';
import 'package:my_expenses/presentation/shared/custom_assets.dart';
import 'package:my_expenses/presentation/shared/styles.dart';
import 'package:my_expenses/presentation/shared/utils/bloc_utils.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DrawerBloc, DrawerState>(
      listener: (ctx, state) {
        if (state.userSignedOut) {
          BlocUtils.raiseAllCommonBlocEvents(ctx);
        }
      },
      builder: (ctx, state) {
        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              _buildHeader(ctx, state),
              _buildItem(AppDrawerItemType.transactions, context, state, (item, ctx) => _onSelectedItem(item, ctx)),
              _buildItem(AppDrawerItemType.reports, context, state, (item, ctx) => _showReportSheet(ctx)),
              _buildItem(AppDrawerItemType.charts, context, state, (item, ctx) => _onSelectedItem(item, ctx)),
              _buildItem(AppDrawerItemType.categories, context, state, (item, ctx) => _onSelectedItem(item, ctx)),
              _buildItem(AppDrawerItemType.estimates, context, state, (item, ctx) => _showEstimatesBottomSheet(ctx)),
              _buildItem(AppDrawerItemType.search, context, state, (item, ctx) => _showSearchPage(ctx)),
              const Divider(),
              _buildItem(AppDrawerItemType.settings, context, state, (item, ctx) => _onSelectedItem(item, ctx)),
              if (state.isUserSignedIn) _buildItem(AppDrawerItemType.logout, context, state, (item, ctx) => _showSignOutDialog(ctx)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    DrawerState state,
  ) {
    final theme = Theme.of(context);
    final i18n = S.of(context);

    return DrawerHeader(
      margin: EdgeInsets.zero,
      // decoration: BoxDecoration(color: Colors.transparent),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () => _signIn(context, state),
              child: state.isUserSignedIn
                  ? Container(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: FileImage(File(state.img!)),
                      ),
                    )
                  : Image.asset(
                      CustomAssets.appIcon,
                      width: 80,
                      height: 80,
                    ),
            ),
            if (!state.isUserSignedIn)
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: Text(
                  i18n.tapToSignIn,
                  style: theme.textTheme.subtitle1,
                ),
              ),
            if (state.isUserSignedIn)
              Flexible(
                child: Tooltip(
                  message: state.fullName!,
                  child: Text(
                    state.fullName!,
                    style: theme.textTheme.subtitle2,
                  ),
                ),
              ),
            if (state.isUserSignedIn)
              Flexible(
                child: Tooltip(
                  message: state.email!,
                  child: Text(
                    state.email!,
                    style: theme.textTheme.caption,
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildItem(
    AppDrawerItemType item,
    BuildContext context,
    DrawerState state,
    Function(AppDrawerItemType, BuildContext) onTap,
  ) {
    final theme = Theme.of(context);
    final i18n = S.of(context);
    String text;
    Icon icon;

    switch (item) {
      case AppDrawerItemType.transactions:
        icon = const Icon(Icons.account_balance);
        text = i18n.transactions;
        break;
      case AppDrawerItemType.reports:
        icon = const Icon(Icons.insert_drive_file);
        text = i18n.reports;
        break;
      case AppDrawerItemType.charts:
        icon = const Icon(Icons.pie_chart);
        text = i18n.charts;
        break;
      case AppDrawerItemType.categories:
        icon = const Icon(Icons.settings);
        text = i18n.categories;
        break;
      case AppDrawerItemType.settings:
        icon = const Icon(Icons.settings);
        text = i18n.config;
        break;
      case AppDrawerItemType.logout:
        icon = const Icon(Icons.arrow_back);
        text = i18n.logout;
        break;
      case AppDrawerItemType.estimates:
        icon = const Icon(Icons.attach_money);
        text = i18n.estimates;
        break;
      case AppDrawerItemType.search:
        icon = const Icon(Icons.search);
        text = i18n.search;
        break;
      default:
        throw Exception('Invalid drawer item = $item');
    }

    final listTitle = ListTile(
      title: Text(text),
      leading: icon,
      onTap: () => onTap(item, context),
    );

    if (state.selectedPage == item) {
      return Ink(
        color: theme.colorScheme.secondary.withOpacity(0.35),
        child: listTitle,
      );
    }

    return listTitle;
  }

  void _onSelectedItem(AppDrawerItemType selectedPage, BuildContext context) {
    context.read<DrawerBloc>().add(DrawerEvent.selectedItemChanged(selectedPage: selectedPage));
    Navigator.pop(context);
  }

  Future<void> _showReportSheet(BuildContext context) async {
    Navigator.pop(context);
    //TODO: IF THE CONTENT IS TO LARGE, WE CANT CLOSE THE SHEET
    await showModalBottomSheet(
      shape: Styles.modalBottomSheetShape,
      isDismissible: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => ReportsBottomSheetDialog(),
    );
  }

  void _showEstimatesBottomSheet(BuildContext context) {
    Navigator.pop(context);
    context.read<EstimatesBloc>().add(EstimatesEvent.load());

    showModalBottomSheet(
      shape: Styles.modalBottomSheetShape,
      isDismissible: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => EstimateBottomSheetDialog(),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    final theme = Theme.of(context);
    final i18n = S.of(context);

    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(i18n.logout),
        content: Text(i18n.confirmSignOut),
        actions: <Widget>[
          OutlinedButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: Text(
              i18n.cancel,
              style: TextStyle(color: theme.primaryColor),
            ),
          ),
          ElevatedButton(
            onPressed: () => _signOut(ctx),
            child: Text(i18n.yes),
          ),
        ],
      ),
    );
  }

  void _signOut(BuildContext context) {
    Navigator.pop(context);
    context.read<DrawerBloc>().add(const DrawerEvent.signOut());
  }

  Future<void> _signIn(BuildContext context, DrawerState state) async {
    Navigator.pop(context);
    return showModalBottomSheet(
      shape: Styles.modalBottomSheetShape,
      isDismissible: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => UserAccountsBottomSheetDialog(),
    );
  }

  Future<void> _showSearchPage(BuildContext context) async {
    Navigator.pop(context);
    context.read<SearchBloc>().add(const SearchEvent.init());
    await Navigator.push(context, SearchPage.route());
  }
}
