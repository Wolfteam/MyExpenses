part of 'sign_in_with_google_bloc.dart';

@freezed
class SignInWithGoogleState with _$SignInWithGoogleState {
  //aka not initialized state
  const factory SignInWithGoogleState.loading() = _LoadingState;

  const factory SignInWithGoogleState.initial({
    required String authUrl,
    required bool isNetworkAvailable,
    @Default(false) bool codeGranted,
    @Default(false) bool flowCompleted,
    @Default(false) bool anErrorOccurred,
  }) = _InitialState;
}
