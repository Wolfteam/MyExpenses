part of 'splash_screen_bloc.dart';

@freezed
sealed class SplashScreenEvent with _$SplashScreenEvent {
  const factory SplashScreenEvent.init() = SplashScreenEventInit;
}
