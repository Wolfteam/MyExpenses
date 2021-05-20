part of 'app_bloc.dart';

@freezed
class AppState with _$AppState {
  const factory AppState.loading({
    ThemeData? theme,
  }) = _LoadingState;

  const factory AppState.loaded({
    required bool isInitialized,
    required ThemeData theme,
    required bool bgTaskIsRunning,
    required LanguageModel language,
  }) = _LoadedState;
}
