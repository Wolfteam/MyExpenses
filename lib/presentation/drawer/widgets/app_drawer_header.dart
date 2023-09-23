import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/drawer/user_accounts_bottom_sheet_dialog.dart';
import 'package:my_expenses/presentation/shared/custom_assets.dart';
import 'package:my_expenses/presentation/shared/styles.dart';

class AppDrawerHeader extends StatelessWidget {
  final bool isUserSignedIn;
  final String? image;
  final String? fullName;
  final String? email;

  const AppDrawerHeader({
    super.key,
    required this.isUserSignedIn,
    this.image,
    this.fullName,
    this.email,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final i18n = S.of(context);
    return DrawerHeader(
      margin: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            InkWell(
              borderRadius: BorderRadius.circular(40),
              onTap: () => _signIn(context),
              child: isUserSignedIn
                  ? Container(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: FileImage(File(image!)),
                      ),
                    )
                  : Image.asset(CustomAssets.appIcon, width: 80, height: 80),
            ),
            if (!isUserSignedIn)
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: Text(
                  i18n.tapToSignIn,
                  style: theme.textTheme.titleMedium,
                ),
              ),
            if (isUserSignedIn)
              Flexible(
                child: Tooltip(
                  message: fullName,
                  child: Text(
                    fullName!,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ),
            if (isUserSignedIn)
              Flexible(
                child: Tooltip(
                  message: email,
                  child: Text(
                    email!,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _signIn(BuildContext context) {
    Navigator.pop(context);
    showModalBottomSheet(
      shape: Styles.modalBottomSheetShape,
      isDismissible: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => UserAccountsBottomSheetDialog(),
    );
  }
}
