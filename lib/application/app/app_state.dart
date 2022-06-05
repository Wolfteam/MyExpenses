part of 'app_bloc.dart';

@freezed
class AppState with _$AppState {
  const factory AppState.loading({
    AppThemeType? theme,
    AppAccentColorType? accentColor,
  }) = _LoadingState;

  const factory AppState.loaded({
    required bool isInitialized,
    required AppThemeType theme,
    required AppAccentColorType accentColor,
    required bool bgTaskIsRunning,
    required LanguageModel language,
    @Default(false) bool forcedSignOut,
  }) = _LoadedState;
}
