import 'package:freezed_annotation/freezed_annotation.dart';

import '../common/enums/app_accent_color_type.dart';
import '../common/enums/app_language_type.dart';
import '../common/enums/app_theme_type.dart';
import '../common/enums/currency_symbol_type.dart';
import '../common/enums/sync_intervals_type.dart';

part 'app_settings.freezed.dart';
part 'app_settings.g.dart';

@freezed
class AppSettings with _$AppSettings {
  const factory AppSettings({
    required AppThemeType appTheme,
    required bool useDarkAmoled,
    required AppAccentColorType accentColor,
    required AppLanguageType appLanguage,
    required SyncIntervalType syncInterval,
    required bool showNotifAfterFullSync,
    required bool askForPassword,
    required bool askForFingerPrint,
    required CurrencySymbolType currencySymbol,
    required bool currencyToTheRight,
    required bool showNotifForRecurringTrans,
    required bool isRecurringTransTaskRegistered,
  }) = _AppSettings;

  factory AppSettings.fromJson(Map<String, dynamic> json) => _$AppSettingsFromJson(json);
}
