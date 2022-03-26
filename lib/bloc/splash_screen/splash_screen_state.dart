part of 'splash_screen_bloc.dart';

@freezed
class SplashScreenState with _$SplashScreenState {
  const factory SplashScreenState.initial({
    required int retries,
    required bool askForPassword,
    required bool askForFingerPrint,
  }) = _InitialState;
}
