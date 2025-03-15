part of 'settings_bloc.dart';

@freezed
sealed class SettingsEvent with _$SettingsEvent {
  const factory SettingsEvent.load() = SettingsEventLoad;

  const factory SettingsEvent.appThemeChanged({required AppThemeType selectedAppTheme}) = SettingsEventAppThemeChanged;

  const factory SettingsEvent.appAccentColorChanged({required AppAccentColorType selectedAccentColor}) =
      SettingsEventAppAccentColorChanged;

  const factory SettingsEvent.appLanguageChanged({required AppLanguageType selectedLanguage}) = SettingsEventAppLanguageChanged;

  const factory SettingsEvent.syncIntervalChanged({
    required SyncIntervalType selectedSyncInterval,
    required BackgroundTranslations translations,
  }) = SettingsEventSyncIntervalChanged;

  const factory SettingsEvent.askForPasswordChanged({required bool ask}) = SettingsEventAskForPasswordChanged;

  const factory SettingsEvent.askForFingerPrintChanged({required bool ask}) = SettingsEventAskForFingerPrintChanged;

  const factory SettingsEvent.currencyChanged({required CurrencySymbolType selectedCurrency}) = SettingsEventCurrencyChanged;

  const factory SettingsEvent.currencyPlacementChanged({required bool placeToTheRight}) = SettingsEventCurrencyPlacementChanged;

  const factory SettingsEvent.showNotificationAfterFullSyncChanged({required bool show}) =
      SettingsEventShowNotificationAfterFullSyncChanged;

  const factory SettingsEvent.showNotificationForRecurringTransChanged({required bool show}) =
      SettingsEventShowNotificationForRecurringTransChanged;

  const factory SettingsEvent.triggerSyncTask({required BackgroundTranslations translations}) = SettingsEventTriggerSyncTask;
}
