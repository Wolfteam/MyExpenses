part of 'settings_bloc.dart';

@freezed
class SettingsEvent with _$SettingsEvent {
  const factory SettingsEvent.load() = _Load;

  const factory SettingsEvent.appThemeChanged({
    required AppThemeType selectedAppTheme,
  }) = _AppThemeChanged;

  const factory SettingsEvent.appAccentColorChanged({
    required AppAccentColorType selectedAccentColor,
  }) = _AppAccentColorChanged;

  const factory SettingsEvent.appLanguageChanged({
    required AppLanguageType selectedLanguage,
  }) = _AppLanguageChanged;

  const factory SettingsEvent.syncIntervalChanged({
    required SyncIntervalType selectedSyncInterval,
    required BackgroundTranslations translations,
  }) = _SyncIntervalChanged;

  const factory SettingsEvent.askForPasswordChanged({
    required bool ask,
  }) = _AskForPasswordChanged;

  const factory SettingsEvent.askForFingerPrintChanged({
    required bool ask,
  }) = _AskForFingerPrintChanged;

  const factory SettingsEvent.currencyChanged({
    required CurrencySymbolType selectedCurrency,
  }) = _CurrencyChanged;

  const factory SettingsEvent.currencyPlacementChanged({
    required bool placeToTheRight,
  }) = _CurrencyPlacementChanged;

  const factory SettingsEvent.showNotificationAfterFullSyncChanged({
    required bool show,
  }) = _ShowNotificationAfterFullSyncChanged;

  const factory SettingsEvent.showNotificationForRecurringTransChanged({
    required bool show,
  }) = _ShowNotificationForRecurringTransChanged;

  const factory SettingsEvent.triggerSyncTask({required BackgroundTranslations translations}) = _TriggerSyncTask;
}
