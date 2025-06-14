part of 'splash_screen_bloc.dart';

@freezed
sealed class SplashScreenState with _$SplashScreenState {
  const factory SplashScreenState.initial({required int retries, required bool askForPassword, required bool askForFingerPrint}) =
      SplashScreenStateInitialState;
}
