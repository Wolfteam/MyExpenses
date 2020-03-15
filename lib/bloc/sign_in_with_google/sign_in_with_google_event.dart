part of 'sign_in_with_google_bloc.dart';

@immutable
abstract class SignInWithGoogleEvent extends Equatable {
  const SignInWithGoogleEvent();
}

class Initialize extends SignInWithGoogleEvent {
  @override
  List<Object> get props => [];
}

class UrlChanged extends SignInWithGoogleEvent {
  final String url;

  @override
  List<Object> get props => [url];

  const UrlChanged(this.url);
}
