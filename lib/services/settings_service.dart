import 'package:shared_preferences/shared_preferences.dart';

import '../common/enums/app_accent_color_type.dart';
import '../common/enums/app_language_type.dart';
import '../common/enums/app_theme_type.dart';
import '../common/enums/currency_symbol_type.dart';
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

  bool get showNotifAfterFullSync;
  set showNotifAfterFullSync(bool show);

  bool get askForPassword;
  set askForPassword(bool ask);

  bool get askForFingerPrint;
  set askForFingerPrint(bool ask);

  CurrencySymbolType get currencySymbol;
  set currencySymbol(CurrencySymbolType type);

  bool get currencyToTheRight;
  set currencyToTheRight(bool toTheRight);

  bool get showNotifForRecurringTrans;
  set showNotifForRecurringTrans(bool show);

  bool get isRecurringTransTaskRegistered;
  set isRecurringTransTaskRegistered(bool itIs);

  Future init();
}

class SettingsServiceImpl implements SettingsService {
  final _appThemeKey = 'AppTheme';
  final _accentColorKey = 'AccentColor';
  final _appLanguageKey = 'AppLanguage';
  final _syncIntervalKey = 'SyncInterval';
  final _showNotifAfterFullSyncKey = 'ShowNotificationAfterFullSync';
  final _askForPasswordKey = 'AskForPassword';
  final _askForFingerPrintKey = 'AskForFingerPrint';
  final _currencySymbolKey = 'CurrencySymbol';
  final _currencyToTheRightKey = 'CurrencyToTheRight';
  final _showNotifForRecurringTransKey = 'ShowNotificationForRecurringTransactions';
  final _recurringTransTaskIsRegisteredKey = 'RecurringTransIsRegistered';

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
        showNotifAfterFullSync: showNotifAfterFullSync,
        askForPassword: askForPassword,
        askForFingerPrint: askForFingerPrint,
        currencySymbol: currencySymbol,
        currencyToTheRight: currencyToTheRight,
        showNotifForRecurringTrans: showNotifForRecurringTrans,
        isRecurringTransTaskRegistered: isRecurringTransTaskRegistered,
      );

  @override
  AppThemeType get appTheme => AppThemeType.values[(_prefs.getInt(_appThemeKey))];
  @override
  set appTheme(AppThemeType theme) => _prefs.setInt(_appThemeKey, theme.index);

  @override
  AppAccentColorType get accentColor => AppAccentColorType.values[_prefs.getInt(_accentColorKey)];
  @override
  set accentColor(AppAccentColorType accentColor) => _prefs.setInt(_accentColorKey, accentColor.index);

  @override
  AppLanguageType get language => AppLanguageType.values[_prefs.getInt(_appLanguageKey)];
  @override
  set language(AppLanguageType lang) => _prefs.setInt(_appLanguageKey, lang.index);

  @override
  SyncIntervalType get syncInterval => SyncIntervalType.values[_prefs.getInt(_syncIntervalKey)];
  @override
  set syncInterval(SyncIntervalType interval) => _prefs.setInt(_syncIntervalKey, interval.index);

  @override
  bool get showNotifAfterFullSync => _prefs.getBool(_showNotifAfterFullSyncKey);
  @override
  set showNotifAfterFullSync(bool show) => _prefs.setBool(
        _showNotifAfterFullSyncKey,
        show,
      );

  @override
  bool get askForPassword => _prefs.getBool(_askForPasswordKey);
  @override
  set askForPassword(bool ask) => _prefs.setBool(_askForPasswordKey, ask);

  @override
  bool get askForFingerPrint => _prefs.getBool(_askForFingerPrintKey);
  @override
  set askForFingerPrint(bool ask) => _prefs.setBool(_askForFingerPrintKey, ask);

  @override
  CurrencySymbolType get currencySymbol => CurrencySymbolType.values[_prefs.getInt(_currencySymbolKey)];
  @override
  set currencySymbol(CurrencySymbolType type) => _prefs.setInt(_currencySymbolKey, type.index);

  @override
  bool get currencyToTheRight => _prefs.getBool(_currencyToTheRightKey);
  @override
  set currencyToTheRight(bool toTheRight) => _prefs.setBool(_currencyToTheRightKey, toTheRight);

  @override
  bool get showNotifForRecurringTrans => _prefs.getBool(_showNotifForRecurringTransKey);
  @override
  set showNotifForRecurringTrans(bool show) => _prefs.setBool(
        _showNotifForRecurringTransKey,
        show,
      );

  @override
  bool get isRecurringTransTaskRegistered => _prefs.getBool(_recurringTransTaskIsRegisteredKey);
  @override
  set isRecurringTransTaskRegistered(bool itIs) => _prefs.setBool(
        _recurringTransTaskIsRegisteredKey,
        itIs,
      );

  SettingsServiceImpl(this._logger);

  @override
  Future init() async {
    if (_initialized) {
      _logger.info(runtimeType, 'Settings are already initialized!');
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

    if (_prefs.get(_showNotifAfterFullSyncKey) == null) {
      _logger.info(
        runtimeType,
        'Setting show notif after full sync to false...',
      );
      _prefs.setBool(_showNotifAfterFullSyncKey, false);
    }

    if (_prefs.get(_askForPasswordKey) == null) {
      _logger.info(runtimeType, 'Setting ask for password to false...');
      _prefs.setBool(_askForPasswordKey, false);
    }

    if (_prefs.get(_askForFingerPrintKey) == null) {
      _logger.info(runtimeType, 'Setting ask for fingerprint to false...');
      _prefs.setBool(_askForFingerPrintKey, false);
    }

    if (_prefs.get(_currencySymbolKey) == null) {
      _logger.info(
        runtimeType,
        'Setting current currency to ${CurrencySymbolType.dolar}...',
      );
      _prefs.setInt(_currencySymbolKey, CurrencySymbolType.dolar.index);
    }

    if (_prefs.get(_currencyToTheRightKey) == null) {
      _logger.info(runtimeType, 'Setting currency to the right to true...');
      _prefs.setBool(_currencyToTheRightKey, true);
    }

    if (_prefs.get(_showNotifForRecurringTransKey) == null) {
      _logger.info(
        runtimeType,
        'Setting show notif for recurring trans to false...',
      );
      _prefs.setBool(_showNotifForRecurringTransKey, false);
    }

    if (_prefs.get(_recurringTransTaskIsRegisteredKey) == null) {
      _logger.info(
        runtimeType,
        'Setting recurring trans task is registered to false...',
      );
      _prefs.setBool(_recurringTransTaskIsRegisteredKey, false);
    }

    _initialized = true;
    _logger.info(runtimeType, 'Settings were initialized successfully');
  }
}
