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
  final bool askForPassword;
  final bool canUseFingerPrint;
  final bool askForFingerPrint;

  final String appName;
  final String appVersion;

  @override
  List<Object> get props => [
        appTheme,
        useDarkAmoled,
        accentColor,
        appLanguage,
        syncInterval,
        askForPassword,
        canUseFingerPrint,
        askForFingerPrint,
        appName,
        appVersion
      ];

  const SettingsInitialState({
    @required this.appTheme,
    @required this.useDarkAmoled,
    @required this.accentColor,
    @required this.appLanguage,
    @required this.syncInterval,
    @required this.askForPassword,
    @required this.canUseFingerPrint,
    @required this.askForFingerPrint,
    @required this.appName,
    @required this.appVersion,
  });

  SettingsInitialState copyWith({
    AppThemeType appTheme,
    bool useDarkAmoled,
    AppAccentColorType accentColor,
    AppLanguageType appLanguage,
    SyncIntervalType syncInterval,
    bool askForPassword,
    bool canUseFingerPrint,
    bool askForFingerPrint,
    String appName,
    String appVersion,
  }) {
    return SettingsInitialState(
      appTheme: appTheme ?? this.appTheme,
      accentColor: accentColor ?? this.accentColor,
      appLanguage: appLanguage ?? this.appLanguage,
      syncInterval: syncInterval ?? this.syncInterval,
      useDarkAmoled: useDarkAmoled ?? this.useDarkAmoled,
      askForPassword: askForPassword ?? this.askForPassword,
      canUseFingerPrint: canUseFingerPrint ?? this.canUseFingerPrint,
      askForFingerPrint: askForFingerPrint ?? this.askForFingerPrint,
      appName: appName ?? this.appName,
      appVersion: appVersion ?? this.appVersion,
    );
  }
}
