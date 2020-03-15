import 'dart:io';

import 'package:flutter/material.dart';

import '../../../generated/i18n.dart';

class UserAccountItem extends StatelessWidget {
  final String fullname;
  final String email;
  final String imgUrl;
  final bool isActive;

  const UserAccountItem({
    this.fullname,
    this.email,
    this.imgUrl,
    this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final i18n = I18n.of(context);
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
              icon: Icon(
                Icons.check_circle_outline,
                color: Colors.green,
              ),
              onPressed: () {},
            ),
          IconButton(
            icon: Icon(
              Icons.delete_forever,
              color: Colors.red,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
