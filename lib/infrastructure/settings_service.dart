import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/extensions/string_extensions.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/domain/services/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _languagesMap = {
  AppLanguageType.english: LanguageModel('en', 'US'),
  AppLanguageType.spanish: LanguageModel('es', 'ES'),
};

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
  final _usesVersionOnePointTwoKey = 'UsesVersionOnePointTwoKey';
  final _nextSyncDateKey = 'LastSyncDateKey';

  final LoggingService _logger;

  bool _initialized = false;

  late SharedPreferences _prefs;

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
  AppThemeType get appTheme => AppThemeType.values[_prefs.getInt(_appThemeKey)!];

  @override
  set appTheme(AppThemeType theme) => _prefs.setInt(_appThemeKey, theme.index);

  @override
  AppAccentColorType get accentColor => AppAccentColorType.values[_prefs.getInt(_accentColorKey)!];

  @override
  set accentColor(AppAccentColorType accentColor) => _prefs.setInt(_accentColorKey, accentColor.index);

  @override
  AppLanguageType get language => AppLanguageType.values[_prefs.getInt(_appLanguageKey)!];

  @override
  set language(AppLanguageType lang) => _prefs.setInt(_appLanguageKey, lang.index);

  @override
  SyncIntervalType get syncInterval => SyncIntervalType.values[_prefs.getInt(_syncIntervalKey)!];

  @override
  set syncInterval(SyncIntervalType interval) {
    _prefs.setInt(_syncIntervalKey, interval.index);
    nextSyncDate = getLastSyncDateToUse(interval);
  }

  @override
  bool get showNotifAfterFullSync => _prefs.getBool(_showNotifAfterFullSyncKey)!;

  @override
  set showNotifAfterFullSync(bool show) => _prefs.setBool(_showNotifAfterFullSyncKey, show);

  @override
  bool get askForPassword => _prefs.getBool(_askForPasswordKey)!;

  @override
  set askForPassword(bool ask) => _prefs.setBool(_askForPasswordKey, ask);

  @override
  bool get askForFingerPrint => _prefs.getBool(_askForFingerPrintKey)!;

  @override
  set askForFingerPrint(bool ask) => _prefs.setBool(_askForFingerPrintKey, ask);

  @override
  CurrencySymbolType get currencySymbol => CurrencySymbolType.values[_prefs.getInt(_currencySymbolKey)!];

  @override
  set currencySymbol(CurrencySymbolType type) => _prefs.setInt(_currencySymbolKey, type.index);

  @override
  bool get currencyToTheRight => _prefs.getBool(_currencyToTheRightKey)!;

  @override
  set currencyToTheRight(bool toTheRight) => _prefs.setBool(_currencyToTheRightKey, toTheRight);

  @override
  bool get showNotifForRecurringTrans => _prefs.getBool(_showNotifForRecurringTransKey)!;

  @override
  set showNotifForRecurringTrans(bool show) => _prefs.setBool(_showNotifForRecurringTransKey, show);

  @override
  bool get isRecurringTransTaskRegistered => _prefs.getBool(_recurringTransTaskIsRegisteredKey)!;

  @override
  set isRecurringTransTaskRegistered(bool itIs) => _prefs.setBool(_recurringTransTaskIsRegisteredKey, itIs);

  bool get usesVersionOnePointTwo => _prefs.getBool(_usesVersionOnePointTwoKey)!;

  set usesVersionOnePointTwo(bool itUsesIt) => _prefs.setBool(_usesVersionOnePointTwoKey, itUsesIt);

  @override
  bool get shouldTriggerSync =>
      (nextSyncDate == null && syncInterval != SyncIntervalType.none) || (nextSyncDate != null && nextSyncDate!.isBefore(DateTime.now()));

  @override
  DateTime? get nextSyncDate {
    final current = _prefs.getString(_nextSyncDateKey);
    if (current.isNullEmptyOrWhitespace) {
      return null;
    }

    return DateTime.parse(current!);
  }

  @override
  set nextSyncDate(DateTime? val) {
    if (val == null) {
      _prefs.setString(_nextSyncDateKey, '');
      return;
    }

    final dateString = val.toString();
    _prefs.setString(_nextSyncDateKey, dateString);
    return;
  }

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
      _logger.info(runtimeType, 'Setting show notif after full sync to false...');
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
      _logger.info(runtimeType, 'Setting current currency to ${CurrencySymbolType.dolar}...');
      _prefs.setInt(_currencySymbolKey, CurrencySymbolType.dolar.index);
    }

    if (_prefs.get(_currencyToTheRightKey) == null) {
      _logger.info(runtimeType, 'Setting currency to the right to true...');
      _prefs.setBool(_currencyToTheRightKey, true);
    }

    if (_prefs.get(_showNotifForRecurringTransKey) == null) {
      _logger.info(runtimeType, 'Setting show notif for recurring trans to false...');
      _prefs.setBool(_showNotifForRecurringTransKey, false);
    }

    if (_prefs.get(_recurringTransTaskIsRegisteredKey) == null) {
      _logger.info(runtimeType, 'Setting recurring trans task is registered to false...');
      _prefs.setBool(_recurringTransTaskIsRegisteredKey, false);
    }

    _initialized = true;
    _logger.info(runtimeType, 'Settings were initialized successfully');
  }

  @override
  LanguageModel getLanguageModel(AppLanguageType lang) => _languagesMap.entries.firstWhere((kvp) => kvp.key == lang).value;

  @override
  LanguageModel getCurrentLanguageModel() => _languagesMap.entries.firstWhere((kvp) => kvp.key == language).value;

  @override
  DateTime? getLastSyncDateToUse(SyncIntervalType interval) {
    final now = DateTime.now();
    switch (interval) {
      case SyncIntervalType.none:
        return null;
      case SyncIntervalType.eachHour:
        return now.add(const Duration(minutes: 60));
      case SyncIntervalType.each3Hours:
        return now.add(const Duration(minutes: 60 * 3));
      case SyncIntervalType.each6Hours:
        return now.add(const Duration(minutes: 60 * 6));
      case SyncIntervalType.each12Hours:
        return now.add(const Duration(minutes: 60 * 12));
      case SyncIntervalType.eachDay:
        return now.add(const Duration(minutes: 60 * 24));
    }
  }

  @override
  void setNextSyncDate() {
    nextSyncDate = getLastSyncDateToUse(syncInterval);
  }
}
