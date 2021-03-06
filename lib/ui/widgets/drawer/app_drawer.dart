import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/drawer/drawer_bloc.dart';
import '../../../bloc/estimates/estimates_bloc.dart';
import '../../../bloc/reports/reports_bloc.dart';
import '../../../bloc/search/search_bloc.dart';
import '../../../bloc/users_accounts/user_accounts_bloc.dart';
import '../../../common/enums/app_drawer_item_type.dart';
import '../../../common/presentation/custom_assets.dart';
import '../../../common/styles.dart';
import '../../../common/utils/bloc_utils.dart';
import '../../../generated/i18n.dart';
import '../../pages/search_page.dart';
import '../estimates/estimate_bottom_sheet_dialog.dart';
import '../reports/reports_bottom_sheet_dialog.dart';
import 'user_accounts_bottom_sheet_dialog.dart';

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
              if (state.isUserSignedIn)
                _buildItem(AppDrawerItemType.logout, context, state, (item, ctx) => _showSignOutDialog(ctx)),
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
    final i18n = I18n.of(context);

    return DrawerHeader(
      margin: const EdgeInsets.all(0),
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
                        backgroundImage: FileImage(File(state.img)),
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
                child: Text(
                  state.fullName,
                  style: theme.textTheme.subtitle2,
                ),
              ),
            if (state.isUserSignedIn)
              Flexible(
                child: Text(
                  state.email,
                  style: theme.textTheme.caption,
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
    final i18n = I18n.of(context);
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
        color: theme.accentColor.withOpacity(0.35),
        child: listTitle,
      );
    }

    return listTitle;
  }

  void _onSelectedItem(AppDrawerItemType selectedPage, BuildContext context) {
    context.bloc<DrawerBloc>().add(DrawerItemSelectionChanged(selectedPage));
    Navigator.pop(context);
  }

  Future<void> _showReportSheet(BuildContext context) async {
    Navigator.pop(context);
    context.bloc<ReportsBloc>().add(const ResetReportSheet());
    //TODO: IF THE CONTENT IS TO LARGE, WE CANT CLOSE THE SHEET
    await showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(35),
          topLeft: Radius.circular(35),
        ),
      ),
      isDismissible: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => ReportsBottomSheetDialog(),
    );
  }

  void _showEstimatesBottomSheet(BuildContext context) {
    Navigator.pop(context);
    context.bloc<EstimatesBloc>().add(EstimatesEvent.load());

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
    final i18n = I18n.of(context);

    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(i18n.logout),
        content: Text(i18n.confirmSignOut),
        actions: <Widget>[
          OutlineButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: Text(
              i18n.cancel,
              style: TextStyle(color: theme.primaryColor),
            ),
          ),
          RaisedButton(
            color: theme.primaryColor,
            onPressed: () => _signOut(ctx),
            child: Text(i18n.yes),
          ),
        ],
      ),
    );
  }

  void _signOut(BuildContext context) {
    Navigator.pop(context);
    context.bloc<DrawerBloc>().add(const SignOut());
  }

  Future<void> _signIn(
    BuildContext context,
    DrawerState state,
  ) async {
    Navigator.pop(context);
    context.bloc<UserAccountsBloc>().add(Initialize());

    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(35),
          topLeft: Radius.circular(35),
        ),
      ),
      isDismissible: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => UserAccountsBottomSheetDialog(),
    );
  }

  Future<void> _showSearchPage(BuildContext context) async {
    Navigator.pop(context);
    await context.bloc<SearchBloc>().init();
    Navigator.push(context, SearchPage.route());
  }
}
