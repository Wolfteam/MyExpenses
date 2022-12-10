part of 'app_bloc.dart';

@freezed
class AppEvent with _$AppEvent {
  const factory AppEvent.init({
    required bool bgTaskIsRunning,
    required BackgroundTranslations translations,
  }) = _Init;

  const factory AppEvent.themeChanged({
    required AppThemeType theme,
  }) = _ThemeChanged;

  const factory AppEvent.accentColorChanged({
    required AppAccentColorType accentColor,
  }) = _AccentColorChanged;

  const factory AppEvent.bgTaskIsRunning({
    required bool isRunning,
  }) = _BgTaskIsRunning;

  const factory AppEvent.languageChanged({
    required AppLanguageType newValue,
  }) = _LanguageChanged;

  const factory AppEvent.registerRecurringBackgroundTask({
    required BackgroundTranslations translations,
  }) = _RegisterRecurringBackgroundTask;

  const factory AppEvent.restart() = _Restart;
}
