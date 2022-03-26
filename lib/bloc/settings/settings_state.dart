part of 'settings_bloc.dart';

@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState.loading() = _LoadingState;

  const factory SettingsState.initial({
    required AppThemeType appTheme,
    required bool useDarkAmoled,
    required AppAccentColorType accentColor,
    required AppLanguageType appLanguage,
    required bool isUserLoggedIn,
    required SyncIntervalType syncInterval,
    required bool showNotificationAfterFullSync,
    required bool askForPassword,
    required bool canUseFingerPrint,
    required bool askForFingerPrint,
    required CurrencySymbolType currencySymbol,
    required bool currencyToTheRight,
    required bool showNotificationForRecurringTrans,
    required String appName,
    required String appVersion,
  }) = _InitialState;
}
