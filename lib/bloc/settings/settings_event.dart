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
