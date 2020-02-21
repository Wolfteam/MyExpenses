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
  final Locale locale;

  const AppInitializedState(this.theme, this.locale);

  @override
  List<Object> get props => [theme];
}
