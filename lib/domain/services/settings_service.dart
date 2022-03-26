import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/models/models.dart';

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

  LanguageModel getLanguageModel(AppLanguageType lang);

  LanguageModel getCurrentLanguageModel();
}
