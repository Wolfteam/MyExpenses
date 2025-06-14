part of 'app_bloc.dart';

@freezed
sealed class AppState with _$AppState {
  const factory AppState.loading() = AppStateLoadingState;

  const factory AppState.loaded({
    required bool isInitialized,
    required AppThemeType theme,
    required AppAccentColorType accentColor,
    required bool bgTaskIsRunning,
    required LanguageModel language,
    @Default(false) bool forcedSignOut,
  }) = AppStateLoadedState;
}
