import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class Styles {
  static final RoundedRectangleBorder cardSettingsShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));
  static final RoundedRectangleBorder floatingCardShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(20));
  static final transactionCardShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(15));

  static const double cardElevation = 3;
  static const edgeInsetAll10 = EdgeInsets.all(10);
  static const edgeInsetAll5 = EdgeInsets.all(5);
  static const edgeInsetAll0 = EdgeInsets.zero;
  static const edgeInsetHorizontal16 = EdgeInsets.symmetric(horizontal: 16);

  static const modalBottomSheetShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.only(topRight: Radius.circular(35), topLeft: Radius.circular(35)),
  );
  static const modalBottomSheetContainerMargin = EdgeInsets.only(left: 10, right: 10, bottom: 10);
  static const modalBottomSheetContainerPadding = EdgeInsets.only(left: 20, right: 20, top: 20);

  static const textStyleGrey12 = TextStyle(fontSize: 12, color: Colors.grey);

  static final popupMenuButtonRadius = BorderRadius.circular(18);

  static const double iconButtonSplashRadius = 20;

  static MonthPickerDialogSettings getMonthPickerDialogSettings(Locale locale, BuildContext context) {
    final theme = Theme.of(context);
    final darkTheme = theme.brightness == Brightness.dark;
    return MonthPickerDialogSettings(
      headerSettings: PickerHeaderSettings(
        headerBackgroundColor: darkTheme ? theme.colorScheme.primaryContainer : theme.colorScheme.primary,
      ),
      dialogSettings: PickerDialogSettings(
        locale: locale,
      ),
      buttonsSettings: PickerButtonsSettings(
        unselectedMonthsTextColor: darkTheme ? Colors.white : Colors.black,
      ),
    );
  }
}
