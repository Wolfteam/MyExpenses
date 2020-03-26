import 'package:shared_preferences/shared_preferences.dart';

import '../common/enums/app_accent_color_type.dart';
import '../common/enums/app_language_type.dart';
import '../common/enums/app_theme_type.dart';
import '../common/enums/sync_intervals_type.dart';
import '../models/app_settings.dart';
import 'logging_service.dart';

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

  bool get askForPassword;
  set askForPassword(bool ask);

  bool get askForFingerPrint;
  set askForFingerPrint(bool ask);

  Future init();
}

class SettingsServiceImpl implements SettingsService {
  final _appThemeKey = 'AppTheme';
  final _accentColorKey = 'AccentColor';
  final _appLanguageKey = 'AppLanguage';
  final _syncIntervalKey = 'SyncInterval';
  final _askForPasswordKey = 'AskForPassword';
  final _askForFingerPrintKey = 'AskForFingerPrint';
  final _passwordKey = 'Password';
  final LoggingService _logger;

  bool _initialized = false;

  SharedPreferences _prefs;

  @override
  AppSettings get appSettings => AppSettings(
        appTheme: appTheme,
        useDarkAmoled: false,
        accentColor: accentColor,
        appLanguage: language,
        syncInterval: syncInterval,
        askForPassword: askForPassword,
        askForFingerPrint: askForFingerPrint,
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

  @override
  bool get askForPassword => _prefs.getBool(_askForPasswordKey);
  @override
  set askForPassword(bool ask) => _prefs.setBool(_askForPasswordKey, ask);

  @override
  bool get askForFingerPrint => _prefs.getBool(_askForFingerPrintKey);
  @override
  set askForFingerPrint(bool ask) => _prefs.setBool(_askForFingerPrintKey, ask);

  SettingsServiceImpl(this._logger);

  @override
  Future init() async {
    if (_initialized) {
      _logger.warning(runtimeType, 'Settings are already initialized!');
      return;
    }

    _logger.info(runtimeType, 'Getting shared prefs instance...');

    _prefs = await SharedPreferences.getInstance();

    if (_prefs.get(_appThemeKey) == null) {
      _logger.info(runtimeType, 'Setting default dark theme');
      _prefs.setInt(_appThemeKey, AppThemeType.dark.index);
    }

    if (_prefs.get(_accentColorKey) == null) {
      _logger.info(runtimeType, 'Setting default blue accent color');
      _prefs.setInt(_accentColorKey, AppAccentColorType.red.index);
    }

    if (_prefs.get(_appLanguageKey) == null) {
      _logger.info(runtimeType, 'Setting english as the default lang');
      _prefs.setInt(_appLanguageKey, AppLanguageType.english.index);
    }

    if (_prefs.get(_syncIntervalKey) == null) {
      _logger.info(runtimeType, 'Setting sync type to none...');
      _prefs.setInt(_syncIntervalKey, SyncIntervalType.none.index);
    }

    if (_prefs.get(_askForPasswordKey) == null) {
      _logger.info(runtimeType, 'Setting ask for password to false...');
      _prefs.setBool(_askForPasswordKey, false);
    }

    if (_prefs.get(_askForFingerPrintKey) == null) {
      _logger.info(runtimeType, 'Setting ask for fingerprint to false...');
      _prefs.setBool(_askForFingerPrintKey, false);
    }

    _initialized = true;
    _logger.info(runtimeType, 'Settings were initialized successfully');
  }
}
