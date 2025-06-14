part of 'app_bloc.dart';

@freezed
sealed class AppEvent with _$AppEvent {
  const factory AppEvent.init({required bool bgTaskIsRunning, required BackgroundTranslations translations}) = AppEventInit;

  const factory AppEvent.themeChanged({required AppThemeType theme}) = AppEventThemeChanged;

  const factory AppEvent.accentColorChanged({required AppAccentColorType accentColor}) = AppEventAccentColorChanged;

  const factory AppEvent.bgTaskIsRunning({required bool isRunning}) = AppEventBgTaskIsRunning;

  const factory AppEvent.languageChanged({required AppLanguageType newValue}) = AppEventLanguageChanged;

  const factory AppEvent.registerRecurringBackgroundTask({required BackgroundTranslations translations}) =
      AppEventRegisterRecurringBackgroundTask;

  const factory AppEvent.restart() = AppEventRestart;
}
