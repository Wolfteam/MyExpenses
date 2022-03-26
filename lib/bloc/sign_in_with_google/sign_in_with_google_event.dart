part of 'sign_in_with_google_bloc.dart';

@freezed
class SignInWithGoogleEvent with _$SignInWithGoogleEvent {
  const factory SignInWithGoogleEvent.init() = _Init;

  const factory SignInWithGoogleEvent.urlChanged({
    required String url,
  }) = _UrlChanged;
}
