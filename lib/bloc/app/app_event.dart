part of 'app_bloc.dart';

abstract class AppEvent extends Equatable {
  const AppEvent();
}

class InitializeApp extends AppEvent {
  final bool bgTaskIsRunning;
  const InitializeApp({this.bgTaskIsRunning});

  @override
  List<Object> get props => [bgTaskIsRunning];
}

class AppThemeChanged extends AppEvent {
  final AppThemeType theme;

  const AppThemeChanged(this.theme);

  @override
  List<Object> get props => [theme];
}

class AppAccentColorChanged extends AppEvent {
  final AppAccentColorType accentColor;

  const AppAccentColorChanged(this.accentColor);

  @override
  List<Object> get props => [accentColor];
}

class AuthenticateUser extends AppEvent {
  @override
  List<Object> get props => [];

  const AuthenticateUser();
}

class BgTaskIsRunning extends AppEvent {
  final bool isRunning;
  
  @override
  List<Object> get props => [isRunning];

  const BgTaskIsRunning({@required this.isRunning});
}
