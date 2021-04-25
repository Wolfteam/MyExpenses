part of 'app_bloc.dart';

@freezed
class AppState with _$AppState {
  const factory AppState.loading() = _LoadingState;

  const factory AppState.loaded({
    required bool isInitialized,
    required ThemeData theme,
    required bool bgTaskIsRunning,
  }) = _LoadedState;

  const factory AppState.auth({
    required int retries,
    required bool askForPassword,
    required bool askForFingerPrint,
    required ThemeData theme,
  }) = _AuthState;
}
