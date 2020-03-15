part of 'sign_in_with_google_bloc.dart';

@immutable
abstract class SignInWithGoogleState extends Equatable {
  const SignInWithGoogleState();
}

class UnninitializedState extends SignInWithGoogleState {
  @override
  List<Object> get props => [];
}

class InitializedState extends SignInWithGoogleState {
  final String authUrl;
  final bool isNetworkAvailable;
  final bool codeGranted;
  final bool flowCompleted;

  @override
  List<Object> get props => [
        authUrl,
        isNetworkAvailable,
        codeGranted,
        flowCompleted,
      ];

  const InitializedState({
    @required this.authUrl,
    @required this.isNetworkAvailable,
    this.codeGranted = false,
    this.flowCompleted = false,
  });

  InitializedState copyWith({
    bool isNetworkAvailable,
    bool codeGranted,
    bool flowCompleted,
  }) {
    return InitializedState(
      authUrl: authUrl,
      isNetworkAvailable: isNetworkAvailable ?? this.isNetworkAvailable,
      codeGranted: codeGranted ?? this.codeGranted,
      flowCompleted: flowCompleted ?? this.flowCompleted,
    );
  }
}
