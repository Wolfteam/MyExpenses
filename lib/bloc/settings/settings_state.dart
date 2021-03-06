part of 'settings_bloc.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();
}

class SettingsLoadingState extends SettingsState {
  @override
  List<Object> get props => [];

  const SettingsLoadingState();
}

class SettingsInitialState extends SettingsState {
  final AppThemeType appTheme;
  final bool useDarkAmoled;
  final AppAccentColorType accentColor;
  final AppLanguageType appLanguage;
  final bool isUserLoggedIn;
  final SyncIntervalType syncInterval;
  final bool showNotifAfterFullSync;
  final bool askForPassword;
  final bool canUseFingerPrint;
  final bool askForFingerPrint;
  final CurrencySymbolType currencySymbol;
  final bool currencyToTheRight;
  final bool showNotifForRecurringTrans;

  final String appName;
  final String appVersion;

  @override
  List<Object> get props => [
        appTheme,
        useDarkAmoled,
        accentColor,
        appLanguage,
        isUserLoggedIn,
        syncInterval,
        showNotifAfterFullSync,
        askForPassword,
        canUseFingerPrint,
        askForFingerPrint,
        appName,
        appVersion,
        currencySymbol,
        currencyToTheRight,
        showNotifForRecurringTrans,
      ];

  const SettingsInitialState({
    @required this.appTheme,
    @required this.useDarkAmoled,
    @required this.accentColor,
    @required this.appLanguage,
    @required this.isUserLoggedIn,
    @required this.syncInterval,
    @required this.showNotifAfterFullSync,
    @required this.askForPassword,
    @required this.canUseFingerPrint,
    @required this.askForFingerPrint,
    @required this.appName,
    @required this.appVersion,
    @required this.currencySymbol,
    @required this.currencyToTheRight,
    @required this.showNotifForRecurringTrans,
  });

  SettingsInitialState copyWith({
    AppThemeType appTheme,
    bool useDarkAmoled,
    AppAccentColorType accentColor,
    AppLanguageType appLanguage,
    bool isUserLoggedIn,
    SyncIntervalType syncInterval,
    bool showNotifAfterFullSync,
    bool askForPassword,
    bool canUseFingerPrint,
    bool askForFingerPrint,
    String appName,
    String appVersion,
    CurrencySymbolType currencySymbol,
    bool currencyToTheRight,
    bool showNotifForRecurringTrans,
  }) {
    return SettingsInitialState(
      appTheme: appTheme ?? this.appTheme,
      accentColor: accentColor ?? this.accentColor,
      appLanguage: appLanguage ?? this.appLanguage,
      isUserLoggedIn: isUserLoggedIn ?? this.isUserLoggedIn,
      syncInterval: syncInterval ?? this.syncInterval,
      showNotifAfterFullSync:
          showNotifAfterFullSync ?? this.showNotifAfterFullSync,
      useDarkAmoled: useDarkAmoled ?? this.useDarkAmoled,
      askForPassword: askForPassword ?? this.askForPassword,
      canUseFingerPrint: canUseFingerPrint ?? this.canUseFingerPrint,
      askForFingerPrint: askForFingerPrint ?? this.askForFingerPrint,
      appName: appName ?? this.appName,
      appVersion: appVersion ?? this.appVersion,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      currencyToTheRight: currencyToTheRight ?? this.currencyToTheRight,
      showNotifForRecurringTrans:
          showNotifForRecurringTrans ?? this.showNotifForRecurringTrans,
    );
  }
}
