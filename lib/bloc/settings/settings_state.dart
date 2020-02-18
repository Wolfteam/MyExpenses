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
  final SyncIntervalType syncInterval;

  @override
  List<Object> get props => [
        appTheme,
        useDarkAmoled,
        accentColor,
        appLanguage,
        syncInterval,
      ];

  const SettingsInitialState({
    @required this.appTheme,
    @required this.useDarkAmoled,
    @required this.accentColor,
    @required this.appLanguage,
    @required this.syncInterval,
  });

  SettingsInitialState copyWith({
    AppThemeType appTheme,
    bool useDarkAmoled,
    AppAccentColorType accentColor,
    AppLanguageType appLanguage,
    SyncIntervalType syncInterval,
  }) {
    return SettingsInitialState(
      appTheme: appTheme ?? this.appTheme,
      accentColor: accentColor ?? this.accentColor,
      appLanguage: appLanguage ?? this.appLanguage,
      syncInterval: syncInterval ?? this.syncInterval,
      useDarkAmoled: useDarkAmoled ?? this.useDarkAmoled,
    );
  }
}
