import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/estimates/estimate_bottom_sheet_dialog.dart';
import 'package:my_expenses/presentation/reports/reports_bottom_sheet_dialog.dart';
import 'package:my_expenses/presentation/shared/dialogs/confirm_dialog.dart';
import 'package:my_expenses/presentation/shared/styles.dart';

class AppDrawerItem extends StatelessWidget {
  final AppDrawerItemType type;
  final bool isSelected;

  const AppDrawerItem({super.key, required this.type, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final i18n = S.of(context);
    String text;
    Icon icon;

    switch (type) {
      case AppDrawerItemType.transactions:
        icon = const Icon(Icons.account_balance);
        text = i18n.transactions;
      case AppDrawerItemType.reports:
        icon = const Icon(Icons.insert_drive_file);
        text = i18n.reports;
      case AppDrawerItemType.categories:
        icon = const Icon(Icons.category);
        text = i18n.categories;
      case AppDrawerItemType.settings:
        icon = const Icon(Icons.settings);
        text = i18n.config;
      case AppDrawerItemType.logout:
        icon = const Icon(Icons.arrow_back);
        text = i18n.logout;
      case AppDrawerItemType.estimates:
        icon = const Icon(Icons.attach_money);
        text = i18n.estimates;
      case AppDrawerItemType.search:
        icon = const Icon(Icons.search);
        text = i18n.search;
      default:
        throw Exception('Invalid drawer item type = $type');
    }

    if (!isSelected) {
      return ListTile(title: Text(text), leading: icon, onTap: () => _onSelectedItem(context));
    }

    return Ink(
      color: theme.colorScheme.secondary.withValues(alpha: 0.35),
      child: ListTile(title: Text(text), leading: icon, onTap: () => _onSelectedItem(context)),
    );
  }

  Future<void> _onSelectedItem(BuildContext context) async {
    if (type == AppDrawerItemType.reports) {
      _showReportSheet(context);
      return;
    }
    if (type == AppDrawerItemType.estimates) {
      _showEstimatesBottomSheet(context);
      return;
    }
    if (type == AppDrawerItemType.logout) {
      _showSignOutDialog(context);
      return;
    }
    context.read<DrawerBloc>().add(DrawerEvent.selectedItemChanged(selectedPage: type));
    Navigator.pop(context);
  }

  void _showReportSheet(BuildContext context) {
    Navigator.pop(context);
    //TODO: IF THE CONTENT IS TO LARGE, WE CANT CLOSE THE SHEET
    showModalBottomSheet(
      shape: Styles.modalBottomSheetShape,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => ReportsBottomSheetDialog(),
    );
  }

  void _showEstimatesBottomSheet(BuildContext context) {
    Navigator.pop(context);
    showModalBottomSheet(
      shape: Styles.modalBottomSheetShape,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => EstimateBottomSheetDialog(),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    final i18n = S.of(context);
    Navigator.pop(context);
    showDialog(
      context: context,
      builder:
          (ctx) => ConfirmDialog(
            title: i18n.logout,
            content: i18n.confirmSignOut,
            okText: i18n.yes,
            onOk: () => ctx.read<DrawerBloc>().add(const DrawerEvent.signOut()),
          ),
    );
  }
}
