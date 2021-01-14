import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/users_accounts/user_accounts_bloc.dart';
import '../../../generated/i18n.dart';

class UserAccountItem extends StatelessWidget {
  final int id;
  final String fullname;
  final String email;
  final String imgUrl;
  final bool isActive;
  final bool canBeDeleted;

  const UserAccountItem({
    this.id,
    this.fullname,
    this.email,
    this.imgUrl,
    this.isActive,
    this.canBeDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(0),
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
    final theme = Theme.of(context);
    final i18n = I18n.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(i18n.confirmation),
        content: Text(i18n.deleteX(fullname)),
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
            onPressed: () {
              Navigator.pop(ctx);
              context.read<UserAccountsBloc>().add(DeleteAccount(id));
            },
            child: Text(i18n.yes),
          ),
        ],
      ),
    );
  }

  void _changeActiveAccount(BuildContext context) {
    context.read<UserAccountsBloc>().add(ChangeActiveAccount(id));
  }
}
