import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../common/enums/app_accent_color_type.dart';
import '../common/enums/app_language_type.dart';
import '../common/enums/app_theme_type.dart';
import '../common/enums/currency_symbol_type.dart';
import '../common/enums/sync_intervals_type.dart';

part 'app_settings.g.dart';

@JsonSerializable()
class AppSettings extends Equatable {
  final AppThemeType appTheme;
  final bool useDarkAmoled;
  final AppAccentColorType accentColor;
  final AppLanguageType appLanguage;
  final SyncIntervalType syncInterval;
  final bool showNotifAfterFullSync;
  final bool askForPassword;
  final bool askForFingerPrint;
  final CurrencySymbolType currencySymbol;
  final bool currencyToTheRight;
  final bool showNotifForRecurringTrans;
  final bool isRecurringTransTaskRegistered;

  @override
  List<Object> get props => [
        appTheme,
        useDarkAmoled,
        accentColor,
        appLanguage,
        syncInterval,
        showNotifAfterFullSync,
        askForPassword,
        askForFingerPrint,
        currencySymbol,
        currencyToTheRight,
        showNotifForRecurringTrans,
        isRecurringTransTaskRegistered,
      ];

  const AppSettings({
    @required this.appTheme,
    @required this.useDarkAmoled,
    @required this.accentColor,
    @required this.appLanguage,
    @required this.syncInterval,
    @required this.showNotifAfterFullSync,
    @required this.askForPassword,
    @required this.askForFingerPrint,
    @required this.currencySymbol,
    @required this.currencyToTheRight,
    @required this.showNotifForRecurringTrans,
    @required this.isRecurringTransTaskRegistered,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$AppSettingsToJson(this);
}
