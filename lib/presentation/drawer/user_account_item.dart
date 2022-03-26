import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/shared/dialogs/confirm_dialog.dart';

class UserAccountItem extends StatelessWidget {
  final int id;
  final String fullname;
  final String email;
  final String imgUrl;
  final bool isActive;
  final bool canBeDeleted;

  const UserAccountItem({
    required this.id,
    required this.fullname,
    required this.email,
    required this.imgUrl,
    required this.isActive,
    required this.canBeDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(fullname),
      subtitle: Text(email),
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: FileImage(File(imgUrl)),
      ),
      trailing: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (!isActive)
            IconButton(
              icon: const Icon(Icons.check_circle_outline, color: Colors.green),
              onPressed: () => _changeActiveAccount(context),
            ),
          if (canBeDeleted)
            IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              onPressed: () => _showDeleteDialog(context),
            ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final i18n = S.of(context);
    showDialog(
      context: context,
      builder: (ctx) => ConfirmDialog(
        title: i18n.confirmation,
        content: i18n.deleteX(fullname),
        okText: i18n.yes,
        onOk: () => context.read<UserAccountsBloc>().add(UserAccountsEvent.deleteAccount(id: id)),
      ),
    );
  }

  void _changeActiveAccount(BuildContext context) {
    context.read<UserAccountsBloc>().add(UserAccountsEvent.changeActiveAccount(newActiveUserId: id));
  }
}
