part of 'app_bloc.dart';

abstract class AppState extends Equatable {
  const AppState();
}

class AppUninitializedState extends AppState {
  @override
  List<Object> get props => [];
}

class AppInitializedState extends AppState {
  final ThemeData theme;

  const AppInitializedState(this.theme);

  @override
  List<Object> get props => [theme];
}

class AuthenticationState extends AppState {
  //used to just change the state
  final int retries;
  final bool askForFingerPrint;
  final ThemeData theme;

  @override
  List<Object> get props => [
        retries,
        askForFingerPrint,
        theme,
      ];

  const AuthenticationState({
    @required this.retries,
    @required this.askForFingerPrint,
    @required this.theme,
  });
}
