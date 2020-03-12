import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/drawer/drawer_bloc.dart';
import '../../bloc/reports/reports_bloc.dart';
import '../../common/enums/app_drawer_item_type.dart';
import '../../common/presentation/custom_assets.dart';
import '../../generated/i18n.dart';
import 'reports/reports_bottom_sheet_dialog.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DrawerBloc, DrawerState>(
      builder: (ctx, state) {
        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              _buildHeader(),
              _buildItem(
                AppDrawerItemType.transactions,
                context,
                state,
                (item, ctx) => _onSelectedItem(
                  item,
                  ctx,
                ),
              ),
              _buildItem(
                AppDrawerItemType.reports,
                context,
                state,
                (item, ctx) => _showReportSheet(ctx),
              ),
              _buildItem(
                AppDrawerItemType.charts,
                context,
                state,
                (item, ctx) => _onSelectedItem(
                  item,
                  ctx,
                ),
              ),
              _buildItem(
                AppDrawerItemType.categories,
                context,
                state,
                (item, ctx) => _onSelectedItem(
                  item,
                  ctx,
                ),
              ),
              const Divider(),
              _buildItem(
                AppDrawerItemType.settings,
                context,
                state,
                (item, ctx) => _onSelectedItem(
                  item,
                  ctx,
                ),
              ),
              // _buildItem(
              //   AppDrawerItemType.logout,
              //   context,
              //   state,
              //   (item, ctx) => _logout(ctx),
              // ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return DrawerHeader(
      margin: const EdgeInsets.all(0),
      decoration: BoxDecoration(color: Colors.transparent),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        // color: Colors.red,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              CustomAssets.appIcon,
              width: 80,
              height: 80,
            ),
            // Flexible(
            //   child: Text(
            //     'Efrain Bastidas',
            //   ),
            // ),
            // Flexible(
            //   child: Text(
            //     'ebastidas@smartersolutions.com.ve',
            //   ),
            // )
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
        icon = Icon(Icons.account_balance);
        text = i18n.transactions;
        break;
      case AppDrawerItemType.reports:
        icon = Icon(Icons.insert_drive_file);
        text = i18n.reports;
        break;
      case AppDrawerItemType.charts:
        icon = Icon(Icons.pie_chart);
        text = i18n.charts;
        break;
      case AppDrawerItemType.categories:
        icon = Icon(Icons.settings);
        text = i18n.categories;
        break;
      case AppDrawerItemType.settings:
        icon = Icon(Icons.settings);
        text = i18n.config;
        break;
      case AppDrawerItemType.logout:
        icon = Icon(Icons.arrow_back);
        text = i18n.logout;
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

  Future _showReportSheet(BuildContext context) async {
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

  void _logout(BuildContext context) {
    Navigator.pop(context);
  }
}
