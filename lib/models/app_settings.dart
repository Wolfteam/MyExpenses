import 'package:flutter/material.dart';

import '../common/enums/app_accent_color_type.dart';
import '../common/enums/app_language_type.dart';
import '../common/enums/app_theme_type.dart';
import '../common/enums/sync_intervals_type.dart';

class AppSettings {
  final AppThemeType appTheme;
  final bool useDarkAmoled;
  final AppAccentColorType accentColor;
  final AppLanguageType appLanguage;
  final SyncIntervalType syncInterval;

  AppSettings({
    @required this.appTheme,
    @required this.useDarkAmoled,
    @required this.accentColor,
    @required this.appLanguage,
    @required this.syncInterval,
  });
}
