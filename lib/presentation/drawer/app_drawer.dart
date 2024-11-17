import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/presentation/drawer/widgets/app_drawer_header.dart';
import 'package:my_expenses/presentation/drawer/widgets/app_drawer_item.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DrawerBloc, DrawerState>(
      builder: (ctx, state) => Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            AppDrawerHeader(
              isUserSignedIn: state.isUserSignedIn,
              image: state.img,
              fullName: state.fullName,
              email: state.email,
            ),
            AppDrawerItem(type: AppDrawerItemType.transactions, isSelected: state.selectedPage == AppDrawerItemType.transactions),
            AppDrawerItem(type: AppDrawerItemType.reports, isSelected: state.selectedPage == AppDrawerItemType.reports),
            AppDrawerItem(type: AppDrawerItemType.categories, isSelected: state.selectedPage == AppDrawerItemType.categories),
            AppDrawerItem(type: AppDrawerItemType.estimates, isSelected: state.selectedPage == AppDrawerItemType.estimates),
            AppDrawerItem(type: AppDrawerItemType.search, isSelected: state.selectedPage == AppDrawerItemType.search),
            const Divider(),
            AppDrawerItem(type: AppDrawerItemType.settings, isSelected: state.selectedPage == AppDrawerItemType.settings),
            if (state.isUserSignedIn)
              AppDrawerItem(
                type: AppDrawerItemType.logout,
                isSelected: state.selectedPage == AppDrawerItemType.logout,
              ),
          ],
        ),
      ),
    );
  }
}
