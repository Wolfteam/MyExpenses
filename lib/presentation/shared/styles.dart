import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class Styles {
  static final RoundedRectangleBorder cardSettingsShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));
  static final RoundedRectangleBorder floatingCardShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(20));
  static final transactionCardShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(15));

  static const double cardElevation = 3;
  static const edgeInsetAll16 = EdgeInsets.all(16);
  static const edgeInsetAll10 = EdgeInsets.all(10);
  static const edgeInsetAll5 = EdgeInsets.all(5);
  static const edgeInsetHorizontal16 = EdgeInsets.symmetric(horizontal: 16);
  static const edgeInsetHorizontal10 = EdgeInsets.symmetric(horizontal: 10);
  static const edgeInsetHorizontal5 = EdgeInsets.symmetric(horizontal: 5);
  static const edgeInsetVertical16 = EdgeInsets.symmetric(vertical: 16);
  static const edgeInsetVertical10 = EdgeInsets.symmetric(vertical: 10);
  static const edgeInsetVertical5 = EdgeInsets.symmetric(vertical: 5);

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
      headerSettings: PickerHeaderSettings(headerBackgroundColor: darkTheme ? theme.colorScheme.primaryContainer : theme.colorScheme.primary),
      dialogSettings: PickerDialogSettings(locale: locale),
      dateButtonsSettings: PickerDateButtonsSettings(unselectedMonthsTextColor: darkTheme ? Colors.white : Colors.black),
    );
  }

  static (TextStyle, BoxDecoration, EdgeInsets) getTooltipStyling(BuildContext context) {
    double getDefaultFontSize(TargetPlatform platform) {
      return switch (platform) {
        TargetPlatform.macOS || TargetPlatform.linux || TargetPlatform.windows => 12.0,
        TargetPlatform.android || TargetPlatform.fuchsia || TargetPlatform.iOS => 14.0,
      };
    }

    final EdgeInsets padding = switch (Theme.of(context).platform) {
      TargetPlatform.macOS || TargetPlatform.linux || TargetPlatform.windows => const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      TargetPlatform.android || TargetPlatform.fuchsia || TargetPlatform.iOS => const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
    };

    final (TextStyle defaultTextStyle, BoxDecoration defaultDecoration) = switch (Theme.of(context)) {
      ThemeData(brightness: Brightness.dark, :final TextTheme textTheme, :final TargetPlatform platform) => (
        textTheme.bodyMedium!.copyWith(color: Colors.black, fontSize: getDefaultFontSize(platform)),
        BoxDecoration(color: Colors.white.withValues(alpha: 0.9), borderRadius: const BorderRadius.all(Radius.circular(4))),
      ),
      ThemeData(brightness: Brightness.light, :final TextTheme textTheme, :final TargetPlatform platform) => (
        textTheme.bodyMedium!.copyWith(color: Colors.white, fontSize: getDefaultFontSize(platform)),
        BoxDecoration(color: Colors.grey[700]!.withValues(alpha: 0.9), borderRadius: const BorderRadius.all(Radius.circular(4))),
      ),
    };

    return (defaultTextStyle, defaultDecoration, padding);
  }
}
