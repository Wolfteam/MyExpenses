part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
}

class LoadSettings extends SettingsEvent {
  const LoadSettings();

  @override
  List<Object> get props => [];
}

class AppThemeChanged extends SettingsEvent {
  final AppThemeType selectedAppTheme;

  const AppThemeChanged(this.selectedAppTheme);

  @override
  List<Object> get props => [selectedAppTheme];
}

class AppAccentColorChanged extends SettingsEvent {
  final AppAccentColorType selectedAccentColor;

  const AppAccentColorChanged(this.selectedAccentColor);

  @override
  List<Object> get props => [selectedAccentColor];
}

class AppLanguageChanged extends SettingsEvent {
  final AppLanguageType selectedLanguage;

  const AppLanguageChanged(this.selectedLanguage);

  @override
  List<Object> get props => [selectedLanguage];
}

class SyncIntervalChanged extends SettingsEvent {
  final SyncIntervalType selectedSyncInterval;

  const SyncIntervalChanged(this.selectedSyncInterval);

  @override
  List<Object> get props => [selectedSyncInterval];
}

class AskForPasswordChanged extends SettingsEvent {
  final bool ask;

  @override
  List<Object> get props => [ask];

  const AskForPasswordChanged({@required this.ask});
}

class AskForFingerPrintChanged extends SettingsEvent {
  final bool ask;

  @override
  List<Object> get props => [ask];

  const AskForFingerPrintChanged({@required this.ask});
}

class CurrencyChanged extends SettingsEvent {
  final CurrencySymbolType selectedCurrency;

  @override
  List<Object> get props => [selectedCurrency];

  const CurrencyChanged(this.selectedCurrency);
}

class CurrencyPlacementChanged extends SettingsEvent {
  final bool placeToTheRight;

  @override
  List<Object> get props => [placeToTheRight];

  const CurrencyPlacementChanged({@required this.placeToTheRight});
}

class ShowNotifAfterFullSyncChanged extends SettingsEvent {
  final bool show;

  @override
  List<Object> get props => [show];

  const ShowNotifAfterFullSyncChanged({@required this.show});
}

class ShowNotifForRecurringTransChanged extends SettingsEvent {
  final bool show;

  @override
  List<Object> get props => [show];

  const ShowNotifForRecurringTransChanged({@required this.show});
}
