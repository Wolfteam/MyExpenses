part of 'app_bloc.dart';

abstract class AppState extends Equatable {
  const AppState();
}

class AppUninitializedState extends AppState {
  @override
  List<Object> get props => [];
}

class AppInitializedState extends AppState {
  final bool isInitialized;
  final ThemeData theme;
  final bool bgTaskIsRunning;

  const AppInitializedState(
    this.theme, {
    this.isInitialized,
    this.bgTaskIsRunning,
  });

  @override
  List<Object> get props => [theme, isInitialized, bgTaskIsRunning];
}

class AuthenticationState extends AppState {
  //used to just change the state
  final int retries;
  final bool askForPassword;
  final bool askForFingerPrint;
  final ThemeData theme;

  @override
  List<Object> get props => [
        retries,
        askForPassword,
        askForFingerPrint,
        theme,
      ];

  const AuthenticationState({
    @required this.retries,
    @required this.askForPassword,
    @required this.askForFingerPrint,
    @required this.theme,
  });
}
