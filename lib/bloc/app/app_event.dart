part of 'app_bloc.dart';

@freezed
class AppEvent with _$AppEvent {
  const factory AppEvent.init({
    required bool bgTaskIsRunning,
  }) = _Init;

  const factory AppEvent.themeChanged({
    required AppThemeType theme,
  }) = _ThemeChanged;

  const factory AppEvent.accentColorChanged({
    required AppAccentColorType accentColor,
  }) = _AccentColorChanged;

  const factory AppEvent.authenticateUser() = _AuthenticateUser;

  const factory AppEvent.bgTaskIsRunning({
    required bool isRunning,
  }) = _BgTaskIsRunning;
}
