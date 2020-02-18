import 'package:shared_preferences/shared_preferences.dart';

import '../common/enums/app_accent_color_type.dart';
import '../common/enums/app_language_type.dart';
import '../common/enums/app_theme_type.dart';
import '../common/enums/sync_intervals_type.dart';
import '../models/app_settings.dart';

abstract class SettingsService {
  AppSettings get appSettings;

  AppThemeType get appTheme;
  set appTheme(AppThemeType theme);

  AppAccentColorType get accentColor;
  set accentColor(AppAccentColorType accentColor);

  AppLanguageType get language;
  set language(AppLanguageType lang);

  SyncIntervalType get syncInterval;
  set syncInterval(SyncIntervalType interval);

  Future init();
}

class SettingsServiceImpl implements SettingsService {
  final _appThemeKey = 'AppTheme';
  final _accentColorKey = 'AccentColor';
  final _appLanguageKey = 'AppLanguage';
  final _syncIntervalKey = 'SyncInterval';

  SharedPreferences _prefs;

  @override
  AppSettings get appSettings => AppSettings(
        appTheme: appTheme,
        useDarkAmoled: false,
        accentColor: accentColor,
        appLanguage: language,
        syncInterval: syncInterval,
      );

  @override
  AppThemeType get appTheme =>
      AppThemeType.values[(_prefs.getInt(_appThemeKey))];
  @override
  set appTheme(AppThemeType theme) => _prefs.setInt(_appThemeKey, theme.index);

  @override
  AppAccentColorType get accentColor =>
      AppAccentColorType.values[_prefs.getInt(_accentColorKey)];
  @override
  set accentColor(AppAccentColorType accentColor) =>
      _prefs.setInt(_accentColorKey, accentColor.index);

  @override
  AppLanguageType get language =>
      AppLanguageType.values[_prefs.getInt(_appLanguageKey)];
  @override
  set language(AppLanguageType lang) =>
      _prefs.setInt(_appLanguageKey, lang.index);

  @override
  SyncIntervalType get syncInterval =>
      SyncIntervalType.values[_prefs.getInt(_syncIntervalKey)];
  @override
  set syncInterval(SyncIntervalType interval) =>
      _prefs.setInt(_syncIntervalKey, interval.index);

  SettingsServiceImpl();

  @override
  Future init() async {
    _prefs = await SharedPreferences.getInstance();

    if (_prefs.get(_appThemeKey) == null) {
      _prefs.setInt(_appThemeKey, AppThemeType.dark.index);
    }

    if (_prefs.get(_accentColorKey) == null) {
      _prefs.setInt(_accentColorKey, AppAccentColorType.blue.index);
    }

    if (_prefs.get(_appLanguageKey) == null) {
      _prefs.setInt(_appLanguageKey, AppLanguageType.english.index);
    }

    if (_prefs.get(_syncIntervalKey) == null) {
      _prefs.setInt(_syncIntervalKey, SyncIntervalType.none.index);
    }
  }
}
