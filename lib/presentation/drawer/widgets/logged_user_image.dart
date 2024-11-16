import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_expenses/domain/extensions/string_extensions.dart';
import 'package:my_expenses/presentation/drawer/user_accounts_bottom_sheet_dialog.dart';
import 'package:my_expenses/presentation/shared/custom_assets.dart';
import 'package:my_expenses/presentation/shared/styles.dart';

class LoggedUserImage extends StatelessWidget {
  final bool isUserSignedIn;
  final String? image;
  final double radius;

  const LoggedUserImage({
    required this.isUserSignedIn,
    required this.image,
    this.radius = 40,
  });

  @override
  Widget build(BuildContext context) {
    if (isUserSignedIn) {
      assert(image.isNotNullEmptyOrWhitespace);
    }
    return InkWell(
      borderRadius: BorderRadius.circular(radius),
      onTap: () => _signIn(context),
      child: isUserSignedIn
          ? CircleAvatar(
              radius: radius,
              backgroundImage: FileImage(File(image!)),
            )
          : Image.asset(
              CustomAssets.appIcon,
              width: radius * 2,
              height: radius * 2,
            ),
    );
  }

  Future<void> _signIn(BuildContext context) {
    // Navigator.pop(context);
    return showModalBottomSheet(
      shape: Styles.modalBottomSheetShape,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => UserAccountsBottomSheetDialog(),
    );
  }
}
